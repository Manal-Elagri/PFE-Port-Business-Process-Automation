package Projet_Stage.PFE.entities;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class DocumentAccess {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Document document;
    private String token;
    private LocalDateTime expiration;
    private Boolean utilise;

    public DocumentAccess() {
    }

    public DocumentAccess(Long id, Document document, String token, LocalDateTime expiration, Boolean utilise) {
        this.id = id;
        this.document = document;
        this.token = token;
        this.expiration = expiration;
        this.utilise = utilise;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Document getDocument() {
        return document;
    }

    public Boolean getUtilise() {
        return utilise;
    }

    public void setUtilise(Boolean utilise) {
        this.utilise = utilise;
    }

    public void setDocument(Document document) {
        this.document = document;
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
}
