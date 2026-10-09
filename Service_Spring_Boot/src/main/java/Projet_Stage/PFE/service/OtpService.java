package Projet_Stage.PFE.service;

import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.repository.DocumentRepository;
import Projet_Stage.PFE.repository.OtpVerificationRepository;
import Projet_Stage.PFE.repository.PersonnelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Random;


@Service
@RequiredArgsConstructor
public class OtpService {


    private final OtpVerificationRepository otpRepository;
    private final EmailService emailService;
    private final DocumentRepository documentRepository;
    private final PersonnelRepository personnelRepository;

    // =========================
    // GENERER + ENVOYER OTP
    // =========================
    public void sendOtp(Document document, Personnel chef) {

        String code = String.valueOf(
                100000 + new Random().nextInt(900000)
        );

        OtpVerification otp = new OtpVerification();

        otp.setCode(code);
        otp.setDocument(document);
        otp.setPersonnel(chef);

        otp.setUsed(false);

        otp.setExpiration(
                LocalDateTime.now().plusMinutes(10)
        );

        otpRepository.disableOldOtps(
                document.getId(),
                chef.getId()
        );

        otpRepository.save(otp);

        emailService.sendEmail(
                chef.getEmail(),
                "Code OTP de signature - Rapport Marsa Maroc",
                "Bonjour " + chef.getPrenom() + " " + chef.getNom() + ",\n\n"
                        + "Un rapport d'opération Marsa Maroc est en attente de votre signature.\n\n"
                        + "Votre code OTP de validation est : " + code + "\n\n"
                        + "Ce code est valable pendant 10 minutes. "
                        + "Veuillez ne pas le partager avec une autre personne.\n\n"
                        + "Cordialement,\n"
                        + "Système Marsa Maroc - TCR Casablanca"
        );
    }


    // =========================
    // VERIFIER OTP
    // =========================
    public void validateOtp(Long documentId,
                            Long personnelId,
                            String code) {

        OtpVerification otp = otpRepository
                .findByDocumentIdAndPersonnelIdAndCode(
                        documentId,
                        personnelId,
                        code
                )
                .orElseThrow(() ->
                        new RuntimeException("OTP invalide"));

        if (Boolean.TRUE.equals(otp.getUsed())) {
            throw new RuntimeException("OTP déjà utilisé");
        }

        if (otp.getExpiration().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("OTP expiré");
        }

        otp.setUsed(true);

        otpRepository.save(otp);
    }

    public void resendOtp(
            Long documentId,
            Long personnelId
    ) {

        Document document = documentRepository.findById(documentId)
                .orElseThrow(() -> new RuntimeException("Document introuvable"));

        Personnel personnel = personnelRepository.findById(personnelId)
                .orElseThrow(() -> new RuntimeException("Personnel introuvable"));

        sendOtp(
                document,
                personnel
        );
    }
}
