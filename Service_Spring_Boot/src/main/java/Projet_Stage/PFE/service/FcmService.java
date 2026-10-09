package Projet_Stage.PFE.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.stereotype.Service;

@Service
public class FcmService {

    public void sendPushNotification(String token, String title, String message) {
        if (token == null || token.isEmpty()) return;

        Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(message)
                .build();

        Message msg = Message.builder()
                .setToken(token)
                .setNotification(notification)
                .build();

        try {
            FirebaseMessaging.getInstance().send(msg);
        } catch (Exception e) {
            System.err.println("❌ Erreur d'envoi push : " + e.getMessage());
        }
    }
}