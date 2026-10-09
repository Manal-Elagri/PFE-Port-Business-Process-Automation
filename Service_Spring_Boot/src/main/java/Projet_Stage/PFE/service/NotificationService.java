package Projet_Stage.PFE.service;

import Projet_Stage.PFE.entities.Notification;
import Projet_Stage.PFE.entities.Operation;
import Projet_Stage.PFE.entities.Personnel;
import Projet_Stage.PFE.enums.StatutNotification;
import Projet_Stage.PFE.enums.TypeNotification;
import Projet_Stage.PFE.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpEntity;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpHeaders;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final RestTemplate restTemplate = new RestTemplate(); // Pour l'appel API

    public void sendWhatsApp(String phone, String message, Operation operation, Personnel personnel) {

        try {
            String pythonUrl = "http://localhost:8001/v1/notifications/send-whatsapp";

            // 1. Préparer les Headers (En-têtes)
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            // ICI : On met la même clé que dans le fichier .env de Python
            headers.set("X-API-Key", "marsa_maroc_2026_secret");

            // 2. Préparer le Body (Le contenu)
            Map<String, String> body = new HashMap<>();
            body.put("phone", phone);
            body.put("message", message);

            // 3. Créer l'entité complète (Headers + Body)
            HttpEntity<Map<String, String>> request = new HttpEntity<>(body, headers);

            // 4. Envoyer la requête
            restTemplate.postForEntity(pythonUrl, request, String.class);
            System.out.println("✅ Notification WhatsApp envoyée");

        } catch (Exception e) {
            System.err.println("❌ Erreur Micro-service Python : " + e.getMessage());
        }

        // 2. Sauvegarde dans votre base PostgreSQL pour l'historique (votre code existant)
        Notification notif = new Notification();
        notif.setType(TypeNotification.WHATSAPP);
        notif.setMessage(message);
        notif.setStatut(StatutNotification.ENVOYE);
        notif.setDateEnvoi(LocalDateTime.now());
        notif.setDestinataire(phone);
        notif.setOperation(operation);
        notif.setPersonnel(personnel);
        notificationRepository.save(notif);
    }
}
