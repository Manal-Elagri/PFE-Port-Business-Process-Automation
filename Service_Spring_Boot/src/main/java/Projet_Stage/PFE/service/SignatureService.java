package Projet_Stage.PFE.service;

import Projet_Stage.PFE.entities.Document;
import Projet_Stage.PFE.entities.OperationResponsable;
import Projet_Stage.PFE.entities.Personnel;
import Projet_Stage.PFE.entities.Signature;
import Projet_Stage.PFE.enums.StatutDocument;
import Projet_Stage.PFE.enums.StatutSignature;
import Projet_Stage.PFE.repository.DocumentRepository;
import Projet_Stage.PFE.repository.OperationResponsableRepository;
import Projet_Stage.PFE.repository.SignatureRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SignatureService {
    private final SignatureRepository signatureRepository;
    private final DocumentRepository documentRepository;
    private final PdfService pdfService;
    private final FileStorageService fileStorageService;
    private final OtpService otpService;
    private final SecurityService securityService;
    private final NotificationService notificationService;
    private final OperationResponsableRepository operationResponsableRepository;

   
    public void initWorkflow(Document document) {

        if (!signatureRepository.findByDocumentId(document.getId()).isEmpty()) {
            return;
        }
        // =========================
        // 1️⃣ Récupérer les responsables de l'opération
        // (ordre de signature défini ici)
        // =========================
        List<OperationResponsable> responsables =
                operationResponsableRepository
                        .findByOperationIdOrderByOrdreSignature(
                                document.getOperation().getId()
                        );

        // =========================
        // 2️⃣ Créer une signature pour chaque responsable
        // =========================
        for (OperationResponsable or : responsables) {

            Signature s = new Signature();

            // lien document
            s.setDocument(document);

            // personne qui doit signer
            s.setSignataire(or.getPersonnel());

            // état initial
            s.setStatut(StatutSignature.EN_ATTENTE);

            // pas encore signé
            s.setDateSignature(null);

            // lien avec workflow métier
            s.setOperationResponsable(or);

            // pas encore de signature image
            s.setSignaturePath(null);

            signatureRepository.save(s);
        }
    }


    // =========================
    // SIGNER DOCUMENT
    // =========================
    @Transactional
    public void signer(Long documentId,
                       Long personnelId,
                       String otpCode,
                       String signaturePath) {

        // =========================
        // 1️⃣ Vérifier OTP
        // =========================
        // Le chef doit entrer le code reçu par email
        otpService.validateOtp(
                documentId,
                personnelId,
                otpCode
        );


        // =========================
        // 2️⃣ Récupérer la signature en attente
        // =========================
        Signature signature = signatureRepository
                .findByDocumentIdAndSignataireId(
                        documentId,
                        personnelId
                )
                .orElseThrow(() ->
                        new RuntimeException("Signature introuvable"));

        Signature currentExpected = getNextSignatureForDocument(signature.getDocument());

        if (currentExpected != null &&
                !currentExpected.getId().equals(signature.getId())) {

            throw new RuntimeException("Ce n'est pas votre tour de signer");
        }


        // Vérifier si déjà signée
        if (signature.getStatut() == StatutSignature.SIGNE) {
            throw new RuntimeException("Document déjà signé");
        }

        if (signature.getStatut() == StatutSignature.EN_COURS) {
            throw new RuntimeException("Signature en cours, veuillez patienter");
        }

        // 🔒 lock immédiat
        signature.setStatut(StatutSignature.EN_COURS);
        signatureRepository.save(signature);


        try {

            // 3️⃣ enregistrer signature
            String savedPath =
                    fileStorageService.saveBase64Signature(
                            signaturePath,
                            "signature_" +
                                    personnelId +
                                    "_" +
                                    documentId +
                                    "_" +
                                    System.currentTimeMillis() +
                                    ".png"
                    );

            signature.setStatut(
                    StatutSignature.SIGNE
            );

            signature.setDateSignature(
                    LocalDateTime.now()
            );

            signature.setSignaturePath(
                    savedPath
            );

            signatureRepository.save(signature);


            // 4️⃣ récupérer document
            Document document =
                    signature.getDocument();


            int ordre = signature.getOperationResponsable().getOrdreSignature();

            int x = 455;
            int y;

            switch (ordre) {
                case 1 -> y = 145;
                case 2 -> y = 100;
                case 3 -> y = 55;
                case 4 -> y = 10;
                default -> y = 10;
            }

            // 5️⃣ mettre à jour PDF
            byte[] updatedPdf =
                    pdfService.addSignatureToExistingPdf(
                            document.getPdfPath(),
                            savedPath,
                            x,
                            y
                    );

            String updatedPath =
                    fileStorageService.save(
                            updatedPdf,
                            "document_" + document.getId() + ".pdf"
                    );

            document.setPdfPath(updatedPath);

            documentRepository.save(document);


            // suite du workflow...
            if (allSignaturesDone(document)) {

                document.setStatut(
                        StatutDocument.SIGNE
                );

                documentRepository.save(document);

                return;
            }

            Signature nextSignature =
                    getNextSignatureForDocument(document);

            if (nextSignature == null) {
                return;
            }

            Personnel nextChef =
                    nextSignature.getSignataire();

            String newLink =
                    securityService.generateSecureLink(
                            document.getId()
                    );

            otpService.sendOtp(
                    document,
                    nextChef
            );
            System.out.println("=== NOTIFICATION NEXT CHEF ===");
            System.out.println("Chef ID = " + nextChef.getId());
            System.out.println("Chef nom = " + nextChef.getNom());
            System.out.println("Chef téléphone = " + nextChef.getTelephone());
            System.out.println("Lien = " + newLink);

            notificationService.sendWhatsApp(
                    nextChef.getTelephone(),
                    "📄 Document prêt pour signature.\n\n"
                            + "Veuillez ouvrir le lien sécurisé suivant :\n"
                            + newLink + "\n\n"
                            + "Un code OTP vous a été envoyé par email.",
                    document.getOperation(),
                    nextChef
            );

        }
        catch (Exception e) {

            // rollback lock
            signature.setStatut(
                    StatutSignature.EN_ATTENTE
            );

            signatureRepository.save(signature);

            throw e;

        }
    }

     // =========================
    // PROCHAIN SIGNATAIRE
   // =========================
     public  Signature getNextSignatureForDocument(Document document) {

        return signatureRepository.findByDocumentId(document.getId())
                .stream()
                .sorted(Comparator.comparing(
                        s -> s.getOperationResponsable().getOrdreSignature()
                ))
                .filter(s -> s.getStatut() == StatutSignature.EN_ATTENTE)
                .findFirst()
                .orElse(null);
    }

    // =========================
    // CHECK SIGNATURES
    // =========================
    private boolean allSignaturesDone(Document document) {

        List<Signature> signatures =
                signatureRepository.findByDocumentId(document.getId());

        return signatures.stream()
                .allMatch(s -> s.getStatut() == StatutSignature.SIGNE);
    }


    public List<Signature> getDocumentSignatures(
            Long documentId
    ) {

        return signatureRepository
                .findByDocumentId(documentId);
    }

    @Transactional
    public void signBySecureLink(
            Document document,
            String otpCode,
            String signatureBase64
    ) {
        Signature nextSignature = getNextSignatureForDocument(document);

        if (nextSignature == null) {
            throw new RuntimeException("Aucune signature en attente");
        }

        Long personnelId = nextSignature.getSignataire().getId();

        signer(
                document.getId(),
                personnelId,
                otpCode,
                signatureBase64
        );
    }


}
