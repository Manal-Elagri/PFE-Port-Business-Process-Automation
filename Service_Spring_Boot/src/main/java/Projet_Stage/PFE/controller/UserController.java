package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.auth.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final AuthService authService;

    @PutMapping("/fcm-token")
    public ResponseEntity<String> updateFcmToken(
            @RequestBody Map<String, String> request
    ) {
        System.out.println("=== UPDATE FCM TOKEN ===");
        System.out.println("TOKEN RECU = " + request.get("fcmToken"));

        authService.updateMyFcmToken(request.get("fcmToken"));

        return ResponseEntity.ok("Token FCM enregistré");
    }
}