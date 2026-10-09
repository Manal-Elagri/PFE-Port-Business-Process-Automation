package Projet_Stage.PFE.auth;

import Projet_Stage.PFE.entities.User;
import Projet_Stage.PFE.repository.PersonnelRepository;
import Projet_Stage.PFE.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;
    private final UserRepository userRepository;

    public AuthController(AuthService authService, UserRepository userRepository) {
        this.authService = authService;

        this.userRepository = userRepository;
    }

    @PostMapping("/login")
    public AuthResponse login(@RequestBody LoginRequest request) {
        return authService.login(request.getIdentifier(), request.getPassword());
    }

    // ================= FORGOT PASSWORD =================
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");

        // Petite validation de sécurité au niveau du contrôleur
        if (email == null || email.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", "L'adresse email est obligatoire"
            ));
        }

        try {
            // Appelle le service qui va générer le CODE et envoyer l'email
            authService.forgotPassword(email);

            // On renvoie un message qui correspond à la nouvelle logique (CODE et non LIEN)
            return ResponseEntity.ok(Map.of(
                    "message", "Un code de sécurité a été envoyé à votre adresse email."
            ));

        } catch (RuntimeException e) {
            // Ici on capture les erreurs jetées par le service (ex: "Utilisateur introuvable")
            // On renvoie un code 400 ou 404 avec le message d'erreur pour Flutter
            return ResponseEntity.status(400).body(Map.of(
                    "error", e.getMessage()
            ));
        }
    }

    // ================= RESET PASSWORD =================
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> request) {

        authService.resetPassword(
                request.get("token"),
                request.get("newPassword")
        );

        return ResponseEntity.ok(Map.of(
                "message", "Mot de passe réinitialisé avec succès"
        ));
    }

    // ================= VALID TOKEN =================
    @GetMapping("/validate-reset-token")
    public ResponseEntity<?> validateToken(@RequestParam String token) {

        User user = authService.validateResetToken(token);

        return ResponseEntity.ok(Map.of(
                "valid", true,
                "email", user.getEmail()
        ));
    }

    @PutMapping("/me/fcm-token")
    public ResponseEntity<?> updateFcmToken(@RequestBody Map<String, String> request) {
        String token = request.get("token");

        // Récupérer l'utilisateur via le JWT envoyé dans le Header
        User user = authService.getAuthenticatedUser();

        user.setFcmToken(token);
        userRepository.save(user);

        return ResponseEntity.ok(Map.of("message", "Token FCM enregistré avec succès"));
    }

}