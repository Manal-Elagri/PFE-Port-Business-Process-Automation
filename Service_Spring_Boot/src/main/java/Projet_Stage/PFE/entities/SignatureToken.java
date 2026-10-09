package Projet_Stage.PFE.entities;


import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class SignatureToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String token;
    private LocalDateTime expiration;
    private Boolean utilise;
    // Ajout IMPORTANT
    private LocalDateTime dateCreation;

    @ManyToOne
    private Signature signature;

    public SignatureToken() {
    }

    public SignatureToken(Long id, String token, LocalDateTime expiration, Boolean utilise, LocalDateTime dateCreation, Signature signature) {
        this.id = id;
        this.token = token;
        this.expiration = expiration;
        this.utilise = utilise;
        this.dateCreation = dateCreation;
        this.signature = signature;
    }

    public LocalDateTime getDateCreation() {
        return dateCreation;
    }

    public void setDateCreation(LocalDateTime dateCreation) {
        this.dateCreation = dateCreation;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public LocalDateTime getExpiration() {
        return expiration;
    }

    public void setExpiration(LocalDateTime expiration) {
        this.expiration = expiration;
    }

    public Boolean getUtilise() {
        return utilise;
    }

    public void setUtilise(Boolean utilise) {
        this.utilise = utilise;
    }

    public Signature getSignature() {
        return signature;
    }

    public void setSignature(Signature signature) {
        this.signature = signature;
    }
}
