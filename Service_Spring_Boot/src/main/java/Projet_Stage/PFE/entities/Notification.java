package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.StatutNotification;
import Projet_Stage.PFE.enums.TypeNotification;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Type : WHATSAPP / EMAIL
    @Enumerated(EnumType.STRING)
    private TypeNotification type;

    // Contenu du message
    private String message;

    // Statut : ENVOYE, ECHEC
    @Enumerated(EnumType.STRING)
    private StatutNotification statut;

    // Date d'envoi
    private LocalDateTime dateEnvoi;

    // Numéro ou email destinataire
    private String destinataire;

    // Lien avec l'opération
    @ManyToOne
    private Operation operation;

    // Lien avec le personnel
    @ManyToOne
    private Personnel personnel;

    public Notification() {
    }

    public Notification(Long id, TypeNotification type, String message, StatutNotification statut, LocalDateTime dateEnvoi, String destinataire, Operation operation, Personnel personnel) {
        this.id = id;
        this.type = type;
        this.message = message;
        this.statut = statut;
        this.dateEnvoi = dateEnvoi;
        this.destinataire = destinataire;
        this.operation = operation;
        this.personnel = personnel;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public TypeNotification getType() {
        return type;
    }

    public void setType(TypeNotification type) {
        this.type = type;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public StatutNotification getStatut() {
        return statut;
    }

    public void setStatut(StatutNotification statut) {
        this.statut = statut;
    }

    public LocalDateTime getDateEnvoi() {
        return dateEnvoi;
    }

    public void setDateEnvoi(LocalDateTime dateEnvoi) {
        this.dateEnvoi = dateEnvoi;
    }

    public String getDestinataire() {
        return destinataire;
    }

    public void setDestinataire(String destinataire) {
        this.destinataire = destinataire;
    }

    public Operation getOperation() {
        return operation;
    }

    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public Personnel getPersonnel() {
        return personnel;
    }

    public void setPersonnel(Personnel personnel) {
        this.personnel = personnel;
    }
}
