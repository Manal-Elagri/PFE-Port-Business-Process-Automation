package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.StatutDocument;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class Document {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDateTime dateGeneration;

    @Enumerated(EnumType.STRING)
    private StatutDocument statut;

    @ManyToOne
    private Operation operation;

    private String pdfPath;  // PDF final signé
    private String draftPdfPath;  // PDF provisoire avant signature

    public Document() {
    }

    public Document(Long id, LocalDateTime dateGeneration, StatutDocument statut, Operation operation, String pdfPath) {
        this.id = id;
        this.dateGeneration = dateGeneration;
        this.statut = statut;
        this.operation = operation;
        this.pdfPath = pdfPath;
    }

    public String getDraftPdfPath() {
        return draftPdfPath;
    }

    public void setDraftPdfPath(String draftPdfPath) {
        this.draftPdfPath = draftPdfPath;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDateTime getDateGeneration() {
        return dateGeneration;
    }

    public void setDateGeneration(LocalDateTime dateGeneration) {
        this.dateGeneration = dateGeneration;
    }

    public StatutDocument getStatut() {
        return statut;
    }

    public void setStatut(StatutDocument statut) {
        this.statut = statut;
    }

    public Operation getOperation() {
        return operation;
    }

    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public String getPdfPath() {
        return pdfPath;
    }

    public void setPdfPath(String pdfPath) {
        this.pdfPath = pdfPath;
    }
}
