package Projet_Stage.PFE.service;

import Projet_Stage.PFE.dto.ArretDTO;
import Projet_Stage.PFE.dto.OperationDocumentDTO;
import Projet_Stage.PFE.dto.request.StartOperationRequest;
import Projet_Stage.PFE.dto.response.OperationResponseDTO;
import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.enums.*;
import Projet_Stage.PFE.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OperationService {

    private final EmployeService employeService;
    private final ScanRepository scanRepository;
    private final OperationRepository operationRepository;
    private final ArretRepository arretRepository;
    private final CauseArretRepository causeArretRepository;
    private final DocumentService documentService;
    private final SignatureService signatureService;
    private final SecurityService securityService;
    private final NotificationService notificationService;
    private final OperationResponsableRepository operationResponsableRepository;
    private final OperationDocumentService operationDocumentService;
    private final PdfService pdfService;
    private final DocumentRepository documentRepository;
    private final FileStorageService fileStorageService;
    private final OtpService otpService;
    private final FcmService fcmService;
    private final UserRepository userRepository;
    private final EscaleRepository escaleRepository;
    private final PosteRepository posteRepository;
    private final PortierRepository portierRepository;
    private final EnginRepository enginRepository;
    private final OperationEnginRepository operationEnginRepository;

    // =========================
    // SECURITY CHECK
    // =========================
    private void validateOperationAccess(Operation operation) {

        Equipe equipe = employeService.getMyCurrentOperationContext();

        if (!operation.getEquipe().getId().equals(equipe.getId())) {
            throw new RuntimeException("Cette opération ne vous appartient pas");
        }
    }

    // =========================
    // VALIDATION OPERATION
    // =========================

    private void validateOperation(Operation op) {

        if (op.getType() == null)
            throw new RuntimeException("Type opération obligatoire");

        if (op.getShift() == null)
            throw new RuntimeException("Shift obligatoire");

        if (op.getEquipe() == null)
            throw new RuntimeException("Equipe obligatoire");

        if (op.getPoste() == null)
            throw new RuntimeException("Poste obligatoire");

        if (op.getPortier() == null)
            throw new RuntimeException("Portier obligatoire");

        if (op.getEscale() == null)
            throw new RuntimeException("Escale obligatoire");

        if (op.getOperationEngins() == null || op.getOperationEngins().isEmpty())
            throw new RuntimeException("Au moins un engin doit être affecté");

        for (OperationEngin oe : op.getOperationEngins()) {

            if (oe == null || oe.getEngin() == null)
                throw new RuntimeException("Engin manquant");

            Engin engin = oe.getEngin();

            if (engin.getEtat() != EtatEngin.ACTIF)
                throw new RuntimeException("Engin non disponible : " + engin.getId());
        }
    }

    // =========================
    // START OPERATION
    // =========================
    @Transactional
    public OperationResponseDTO startOperation(StartOperationRequest request) {

        if (!employeService.canStartOperation()) {
            throw new RuntimeException("Shift inactive ou accès refusé");
        }

        Equipe equipe = employeService.getMyCurrentOperationContext();

        if (equipe == null) {
            throw new RuntimeException("Equipe introuvable");
        }

        if (equipe.getShift() == null) {
            throw new RuntimeException("Shift obligatoire");
        }

        if (request.getEnginIds() == null || request.getEnginIds().isEmpty()) {
            throw new RuntimeException("Au moins un engin doit être sélectionné");
        }

        Operation op = new Operation();

        op.setType(TypeOperation.valueOf(request.getType()));
        op.setStatut(StatutOperation.EN_COURS);
        op.setDateDebut(LocalDateTime.now());
        op.setEquipe(equipe);
        op.setShift(equipe.getShift());

        op.setNombreConteneurs(
                request.getNombreConteneurs() != null
                        ? request.getNombreConteneurs()
                        : 0
        );

        op.setEscale(
                escaleRepository.findById(request.getEscaleId())
                        .orElseThrow(() -> new RuntimeException("Escale introuvable"))
        );

        op.setPoste(
                posteRepository.findById(request.getPosteId())
                        .orElseThrow(() -> new RuntimeException("Poste introuvable"))
        );

        op.setPortier(
                portierRepository.findById(request.getPortierId())
                        .orElseThrow(() -> new RuntimeException("Portier introuvable"))
        );

        List<OperationEngin> operationEngins = request.getEnginIds()
                .stream()
                .map(enginId -> {
                    Engin engin = enginRepository.findById(enginId)
                            .orElseThrow(() -> new RuntimeException("Engin introuvable : " + enginId));

                    OperationEngin oe = new OperationEngin();
                    oe.setOperation(op);
                    oe.setEngin(engin);

                    return oe;
                })
                .toList();

        op.setOperationEngins(operationEngins);

        validateOperation(op);

        operationRepository.save(op);
        operationEnginRepository.saveAll(operationEngins);

        return new OperationResponseDTO(
                op.getId(),
                op.getStatut().name(),
                op.getDateDebut(),
                op.getNombreConteneurs()
        );
    }

    // =========================
    // PAUSE
    // =========================
    public void pauseOperation(Long operationId) {

        Operation op = getOperation(operationId);
        validateOperationAccess(op);

        if (hasOpenArret(operationId))
            throw new RuntimeException("Un arrêt est déjà en cours");

        if (op.getStatut() != StatutOperation.EN_COURS)
            throw new RuntimeException("Operation non active");

        op.setStatut(StatutOperation.PAUSE);
        operationRepository.save(op);
    }

    // =========================
    // RESUME
    // =========================
    public void resumeOperation(Long operationId) {

        Operation op = getOperation(operationId);

        validateOperationAccess(op);

        if (hasOpenArret(operationId))
            throw new RuntimeException("Arrêt actif → reprise impossible");

        if (op.getStatut() != StatutOperation.PAUSE)
            throw new RuntimeException("Operation non en pause");

        op.setStatut(StatutOperation.EN_COURS);
        operationRepository.save(op);
    }

    // =========================
    // ARRET MANUEL
    // =========================
    @Transactional
    public ArretDTO arretManuel(Long operationId) {

        Operation op = getOperation(operationId);

        validateOperationAccess(op);

        if (hasOpenArret(operationId))
            throw new RuntimeException("Un arrêt est déjà en cours");

        Arret arret = new Arret();
        arret.setDateDebut(LocalDateTime.now());
        arret.setType(TypeArret.MANUEL);
        arret.setOperation(op);

        arretRepository.save(arret);

        op.setStatut(StatutOperation.PAUSE);
        operationRepository.save(op);

        return mapToArretDTO(arret);
    }

    // =========================
    // ARRET AUTOMATIQUE
    // =========================
    public void detectArretAuto() {

        List<Operation> operations =
                operationRepository.findByStatut(StatutOperation.EN_COURS);

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime limit = now.minusMinutes(10);

        for (Operation op : operations) {

            if (hasOpenArret(op.getId())) {
                continue;
            }

            LocalDateTime lastScan =
                    scanRepository.findLastScanTime(op.getId());

            // Si aucun scan n'existe encore, on utilise dateDebut.
            // Comme ça, une nouvelle opération a 10 minutes pour faire son premier scan.
            LocalDateTime lastActivity =
                    lastScan != null ? lastScan : op.getDateDebut();

            if (lastActivity == null) {
                continue;
            }

            boolean noActivity = lastActivity.isBefore(limit);

            if (!noActivity) {
                continue;
            }

            Arret arret = new Arret();
            arret.setDateDebut(now);
            arret.setType(TypeArret.AUTOMATIQUE);
            arret.setOperation(op);

            arretRepository.save(arret);

            op.setStatut(StatutOperation.PAUSE);
            operationRepository.save(op);
        }
    }

    // =========================
    // TERMINER ARRET
    // =========================
    @Transactional
    public ArretDTO terminerArret(Long arretId, String causeText) {

        if (causeText == null || causeText.trim().isBlank()) {
            throw new RuntimeException("Cause obligatoire");
        }

        Arret arret = arretRepository.findById(arretId)
                .orElseThrow(() -> new RuntimeException("Arrêt introuvable"));

        if (arret.getDateFin() != null) {
            throw new RuntimeException("Arrêt déjà clôturé");
        }

        CauseArret cause = causeArretRepository
                .findByLibelleIgnoreCase(causeText.trim())
                .orElseGet(() -> {
                    CauseArret newCause = new CauseArret();
                    newCause.setLibelle(causeText.trim());
                    newCause.setDescription(causeText.trim());
                    return causeArretRepository.save(newCause);
                });

        arret.setCause(cause);
        arret.setDateFin(LocalDateTime.now());

        Arret saved = arretRepository.save(arret);

        Operation operation = saved.getOperation();
        operation.setStatut(StatutOperation.EN_COURS);
        operationRepository.save(operation);

        return new ArretDTO(
                saved.getId(),
                saved.getType().name(),
                saved.getDateDebut(),
                saved.getDateFin(),
                saved.getCause() != null ? saved.getCause().getLibelle() : null
        );
    }

    // =========================
    // TERMINER OPERATION
    // =========================
    @Transactional
    public void terminerOperation(Long operationId) {

        // =========================
        // 1️⃣ Vérifications
        // =========================
        Operation op = getOperation(operationId);

        validateOperationAccess(op);

        if (op.getStatut() == StatutOperation.TERMINE)
            throw new RuntimeException("Déjà terminée");

        if (hasOpenArret(operationId))
            throw new RuntimeException("Arrêt non clôturé");

        Long totalScans =
                scanRepository.countByOperationId(
                        operationId
                );

        if (totalScans == 0) {
            throw new RuntimeException(
                    "Aucun scan effectué"
            );
        }
        // =========================
        // 2️⃣ Clôturer opération
        // =========================
        op.setStatut(StatutOperation.TERMINE);
        op.setDateFin(LocalDateTime.now());

        //  RESPONSABLES (IMPORTANT AVANT WORKFLOW)
        assignResponsables(op);

        operationRepository.save(op);
        operationRepository.flush(); // 🔥 IMPORTANT
        // =========================
        // 3️⃣ Créer document
        // =========================
        Document doc = documentService.createDocument(op);

        // =========================
        // 4️⃣ Générer données document
        // =========================
        OperationDocumentDTO dto =
                operationDocumentService.generateDocument(op.getId());

        // =========================
        // 5️⃣ Générer lien sécurisé
        // =========================
        String link = securityService.generateSecureLink(doc.getId());

        // =========================
        // 6️⃣ Générer PDF (DRAFT)
        // =========================
        byte[] draftPdf = pdfService.generateOperationPdf(dto, link);

        // =========================
        // 7️⃣ Sauvegarder PDF
        // =========================
        String draftPath = fileStorageService.save(
                draftPdf,
                "operation_" + op.getId() + ".pdf"
        );

        doc.setPdfPath(draftPath);
        documentRepository.save(doc);

        // =========================
        // 8️⃣ Init signatures
        // =========================
        signatureService.initWorkflow(doc);

        // =========================
        // 9️⃣ Récupérer 1er signataire
        // =========================
        OperationResponsable firstResponsable =
                operationResponsableRepository
                        .findFirstByOperationIdOrderByOrdreSignatureAsc(op.getId())
                        .orElseThrow(() -> new RuntimeException("Aucun responsable"));

        Personnel firstChef = firstResponsable.getPersonnel();

        // =========================
        // 🔟 Notifications (WhatsApp + FCM + OTP)
        // =========================

        // --- NOUVEAU : Envoi de la notification Push via FCM ---
        userRepository.findByPersonnelId(firstChef.getId()).ifPresentOrElse(user -> {

            System.out.println("FCM USER FOUND: " + user.getId());
            System.out.println("FCM TOKEN: " + user.getFcmToken());

            if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                fcmService.sendPushNotification(
                        user.getFcmToken(),
                        "Signature requise - Marsa Maroc",
                        "Le rapport pour l'opération #" + op.getId() + " est prêt pour validation."
                );
            } else {
                System.out.println("FCM NON ENVOYE: token vide");
            }

        }, () -> {
            System.out.println("FCM NON ENVOYE: aucun user pour personnel " + firstChef.getId());
        });

        // =========================
        //  Notification WhatsApp  & OTP par email
        // =========================
        String message = "Document prêt pour validation.\n\n" + link;

        notificationService.sendWhatsApp(
                firstChef.getTelephone(),
                message,
                doc.getOperation(),
                firstChef
        );
        // OTP par email
        otpService.sendOtp(doc, firstChef);
    }



    // =========================
    // UTILS
    // =========================
    private Operation getOperation(Long id) {
        return operationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Operation not found"));
    }

    private boolean hasOpenArret(Long operationId) {
        return arretRepository.existsByOperationIdAndDateFinIsNull(operationId);
    }

    public List<ArretDTO> getArretsEnCours(Long operationId) {

        List<Arret> arrets = arretRepository.findByOperationIdAndDateFinIsNull(operationId);

        return arrets.stream()
                .map(this::mapToArretDTO)
                .toList();
    }

    private ArretDTO mapToArretDTO(Arret a) {

        return new ArretDTO(
                a.getId(),
                a.getType() != null ? a.getType().name() : null,
                a.getDateDebut(),
                a.getDateFin(),
                a.getCause() != null ? a.getCause().getLibelle() : null
        );
    }


    private void assignResponsables(Operation op) {

        if (!operationResponsableRepository
                .findByOperationIdOrderByOrdreSignature(op.getId())
                .isEmpty()) {
            return;
        }

        Equipe equipe = op.getEquipe();
        Shift shift = op.getShift();

        if (equipe.getChefEquipe() == null)
            throw new RuntimeException("Chef équipe manquant");

        if (equipe.getChefEscale() == null)
            throw new RuntimeException("Chef escale manquant");

        if (shift.getChefService() == null)
            throw new RuntimeException("Chef service manquant");

        if (shift.getChefDivision() == null)
            throw new RuntimeException("Chef division manquant");

        saveResponsable(op, equipe.getChefEquipe(), RolePersonnel.CHEF_EQUIPE, 1);

        saveResponsable(op, equipe.getChefEscale(), RolePersonnel.CHEF_ESCALE, 2);

        saveResponsable(op, shift.getChefService(), RolePersonnel.CHEF_SERVICE, 3);

        saveResponsable(op, shift.getChefDivision(), RolePersonnel.CHEF_DIVISION, 4);
    }

    private void saveResponsable(
            Operation op,
            Personnel personnel,
            RolePersonnel role,
            int ordre
    ) {

        OperationResponsable responsable =
                new OperationResponsable();

        responsable.setOperation(op);

        responsable.setPersonnel(personnel);

        responsable.setRole(role);

        responsable.setOrdreSignature(ordre);

        responsable.setStatut(StatutSignature.EN_ATTENTE);

        operationResponsableRepository.save(responsable);
    }

    public Operation findById(Long id) {
        return operationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Operation introuvable"));
    }

}