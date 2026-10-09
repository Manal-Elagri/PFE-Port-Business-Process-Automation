package Projet_Stage.PFE.auth;

import Projet_Stage.PFE.entities.User;
import Projet_Stage.PFE.repository.UserRepository;
import Projet_Stage.PFE.security.JwtService;
import Projet_Stage.PFE.service.EmailService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;


    public AuthResponse login(String identifier, String password) {

        User user = userRepository.findByEmail(identifier)
                .or(() -> userRepository.findByCin(identifier))
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("Mot de passe incorrect");
        }

        String token = jwtService.generateToken(user);

        return new AuthResponse(
                token,
                user.getRole(),
                user.getPersonnel().getNom()
        );
    }

    // ================= FORGOT PASSWORD =================
    public void forgotPassword(String email) {

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        // Protection anti-spam reset
        if (user.getResetToken() != null &&
                user.getResetTokenExpiry() != null &&
                user.getResetTokenExpiry().isAfter(LocalDateTime.now())) {
            throw new RuntimeException("Un code de réinitialisation vous a déjà été envoyé.");
        }

        // On génère un code court et lisible ou on garde l'UUID (plus sécurisé)
        // Ici on garde l'UUID mais on l'envoie comme un "Code de validation"
        String token = UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        user.setResetToken(token);
        user.setResetTokenExpiry(LocalDateTime.now().plusMinutes(30));

        userRepository.save(user);

        // Message optimisé pour Flutter
        String message =
                "Bonjour " + user.getPersonnel().getNom() + ",\n\n" +
                        "Vous avez demandé la réinitialisation de votre mot de passe pour votre compte Marsa Maroc.\n\n" +
                        "Veuillez saisir le code de sécurité suivant dans votre application mobile :\n\n" +
                        "CODE : " + token + "\n\n" +
                        "Ce code est valable pendant 30 minutes.\n\n" +
                        "Si vous n'êtes pas à l'origine de cette demande, vous pouvez ignorer cet email en toute sécurité.\n\n" +
                        "L'équipe technique TCR.";

        emailService.sendEmail(
                user.getEmail(),
                "Votre code de récupération Marsa Maroc",
                message
        );
    }

    // ================= VALID TOKEN =================
    public User validateResetToken(String token) {

        User user = userRepository.findByResetToken(token)
                .orElseThrow(() -> new RuntimeException("Token invalide"));

        if (user.getResetTokenExpiry() == null ||
                user.getResetTokenExpiry().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Token expiré");
        }

        return user;
    }

    // ================= RESET PASSWORD =================
    public void resetPassword(String token, String newPassword) {

        if (newPassword == null || newPassword.length() < 6) {
            throw new RuntimeException("Mot de passe trop faible");
        }

        User user = validateResetToken(token);

        user.setPassword(passwordEncoder.encode(newPassword));

        user.setResetToken(null);
        user.setResetTokenExpiry(null);

        userRepository.save(user);
    }


    // Ajoutez ceci dans AuthService.java

    public void updateFcmToken(User user, String token) {
        user.setFcmToken(token);
        userRepository.save(user);
    }

    public User getAuthenticatedUser() {
        Object principal = org.springframework.security.core.context.SecurityContextHolder
                .getContext().getAuthentication().getPrincipal();

        if (principal instanceof User) {
            return (User) principal;
        }
        throw new RuntimeException("Utilisateur non connecté");
    }

    @Transactional
    public void updateMyFcmToken(String fcmToken) {
        if (fcmToken == null || fcmToken.isBlank()) {
            throw new RuntimeException("Token FCM vide");
        }



        String username = SecurityContextHolder
                .getContext()
                .getAuthentication()
                .getName();

        User user = userRepository.findByEmail(username)
                .or(() -> userRepository.findByCin(username))
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        System.out.println("=== SAVE FCM TOKEN ===");
        System.out.println("USER CONNECTE = " + username);
        System.out.println("FCM TOKEN = " + fcmToken);

        user.setFcmToken(fcmToken);
        userRepository.save(user);
    }
}