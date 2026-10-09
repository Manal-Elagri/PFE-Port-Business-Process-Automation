package Projet_Stage.PFE.service;

import Projet_Stage.PFE.entities.Conges;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

     // =========================
    // ENVOYER EMAIL
    // =========================

    public void sendSimpleMessage(String email, String subject, String text) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("tcr.marsamaroc@gmail.com");
        message.setTo(email);
        message.setSubject(subject);
        message.setText(text);
        mailSender.send(message);
    }

    public void sendEmail(String to,
                          String subject,
                          String message) {

        try {

            SimpleMailMessage mail =
                    new SimpleMailMessage();

            mail.setTo(to);
            mail.setSubject(subject);
            mail.setText(message);

            mailSender.send(mail);

        } catch (Exception e) {

            throw new RuntimeException(
                    "Erreur envoi email",
                    e
            );
        }
    }



    public void sendCongeStatutNotification(String email, String employeNom,
                                            LocalDate dateDebut, LocalDate dateFin,
                                            Conges.StatutConge newStatus) {
        String subject = "Mise à jour de votre demande de congé";
        String message = String.format(
                "Bonjour %s,\n\n" +
                        "Votre demande de congé du %s au %s a été mise à jour.\n\n" +
                        "📌 Nouveau statut : %s\n\n" +
                        "Si vous avez des questions, n'hésitez pas à nous contacter.\n\n" +
                        "Cordialement,\n" +
                        "L'équipe Marsa Maroc",
                employeNom,
                dateDebut,   // 2
                dateFin,     // 3
                newStatus.toString() // 4
        );

        sendSimpleMessage(email, subject, message);
    }


}
