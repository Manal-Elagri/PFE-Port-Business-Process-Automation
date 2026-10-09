package Projet_Stage.PFE.entities;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class OtpVerification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String code;

    private LocalDateTime expiration;

    private Boolean used = false;

    @ManyToOne
    private Personnel personnel;

    @ManyToOne
    private Document document;

    public OtpVerification() {
    }

    public OtpVerification(Long id, String code, LocalDateTime expiration, Boolean used, Personnel personnel, Document document) {
        this.id = id;
        this.code = code;
        this.expiration = expiration;
        this.used = used;
        this.personnel = personnel;
        this.document = document;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public LocalDateTime getExpiration() {
        return expiration;
    }

    public void setExpiration(LocalDateTime expiration) {
        this.expiration = expiration;
    }

    public Boolean getUsed() {
        return used;
    }

    public void setUsed(Boolean used) {
        this.used = used;
    }

    public Personnel getPersonnel() {
        return personnel;
    }

    public void setPersonnel(Personnel personnel) {
        this.personnel = personnel;
    }

    public Document getDocument() {
        return document;
    }

    public void setDocument(Document document) {
        this.document = document;
    }
}
