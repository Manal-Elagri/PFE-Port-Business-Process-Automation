package Projet_Stage.PFE.entities;


import Projet_Stage.PFE.enums.RoleUser;
import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.Date;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String cin; // login pour ouvriers / employés

    private String email;   // ✅ LOGIN CHEF
    private String password;

    @Enumerated(EnumType.STRING)
    private RoleUser role;

    @OneToOne
    private Personnel personnel;

    ///--------------------Concernent password oublier -------------

    @Column(name = "reset_token")
    private String resetToken;

    @Column(name = "reset_token_expiry")
    private LocalDateTime resetTokenExpiry;

    @Column(name = "fcm_token")
    private String fcmToken; // Le jeton Firebase du téléphone de l'utilisateur


    public User() {
    }

    public User(Long id, String cin, String email, String password, RoleUser role, Personnel personnel, String resetToken, LocalDateTime resetTokenExpiry, String fcmToken) {
        this.id = id;
        this.cin = cin;
        this.email = email;
        this.password = password;
        this.role = role;
        this.personnel = personnel;
        this.resetToken = resetToken;
        this.resetTokenExpiry = resetTokenExpiry;
        this.fcmToken = fcmToken;
    }

    public String getFcmToken() {
        return fcmToken;
    }

    public void setFcmToken(String fcmToken) {
        this.fcmToken = fcmToken;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCin() {
        return cin;
    }

    public void setCin(String cin) {
        this.cin = cin;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public RoleUser getRole() {
        return role;
    }

    public void setRole(RoleUser role) {
        this.role = role;
    }

    public Personnel getPersonnel() {
        return personnel;
    }

    public void setPersonnel(Personnel personnel) {
        this.personnel = personnel;
    }

    public String getResetToken() {
        return resetToken;
    }

    public void setResetToken(String resetToken) {
        this.resetToken = resetToken;
    }

    public LocalDateTime getResetTokenExpiry() {
        return resetTokenExpiry;
    }

    public void setResetTokenExpiry(LocalDateTime resetTokenExpiry) {
        this.resetTokenExpiry = resetTokenExpiry;
    }
}
