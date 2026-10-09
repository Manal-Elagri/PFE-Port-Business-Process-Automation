package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.StatutSignature;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class Signature {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Date de signature
    private LocalDateTime dateSignature;

    // Statut : EN_ATTENTE, SIGNE, REFUSE
    @Enumerated(EnumType.STRING)
    private StatutSignature statut;

    // Lien avec le document
    @ManyToOne
    private Document document;

    // Qui doit signer
    @ManyToOne
    private Personnel signataire;

    // Signature manuscrite
    private String signaturePath; // image

    @ManyToOne
    private OperationResponsable operationResponsable; // 🔥 important

    @Version
    private Long version;

    public Signature() {
    }

    public Signature(Long id, LocalDateTime dateSignature, StatutSignature statut, Document document, Personnel signataire, String signaturePath, OperationResponsable operationResponsable) {
        this.id = id;
        this.dateSignature = dateSignature;
        this.statut = statut;
        this.document = document;
        this.signataire = signataire;
        this.signaturePath = signaturePath;
        this.operationResponsable = operationResponsable;
    }


    public Long getVersion() {
        return version;
    }

    public void setVersion(Long version) {
        this.version = version;
    }

    public String getSignaturePath() {
        return signaturePath;
    }

    public void setSignaturePath(String signaturePath) {
        this.signaturePath = signaturePath;
    }

    public OperationResponsable getOperationResponsable() {
        return operationResponsable;
    }

    public void setOperationResponsable(OperationResponsable operationResponsable) {
        this.operationResponsable = operationResponsable;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDateTime getDateSignature() {
        return dateSignature;
    }

    public void setDateSignature(LocalDateTime dateSignature) {
        this.dateSignature = dateSignature;
    }

    public StatutSignature getStatut() {
        return statut;
    }

    public void setStatut(StatutSignature statut) {
        this.statut = statut;
    }

    public Document getDocument() {
        return document;
    }

    public void setDocument(Document document) {
        this.document = document;
    }

    public Personnel getSignataire() {
        return signataire;
    }

    public void setSignataire(Personnel signataire) {
        this.signataire = signataire;
    }
}
