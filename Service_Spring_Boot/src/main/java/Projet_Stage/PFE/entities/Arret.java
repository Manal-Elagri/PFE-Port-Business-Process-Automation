package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.TypeArret;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class Arret {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDateTime dateDebut;
    private LocalDateTime dateFin;

    @Enumerated(EnumType.STRING)
    private TypeArret type;

    @ManyToOne private Operation operation;
    @ManyToOne
    private CauseArret cause;

    public Arret() {
    }

    public Arret(Long id, LocalDateTime dateDebut, LocalDateTime dateFin, TypeArret type, Operation operation, CauseArret cause) {
        this.id = id;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
        this.type = type;
        this.operation = operation;
        this.cause = cause;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDateTime getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(LocalDateTime dateDebut) {
        this.dateDebut = dateDebut;
    }

    public LocalDateTime getDateFin() {
        return dateFin;
    }

    public void setDateFin(LocalDateTime dateFin) {
        this.dateFin = dateFin;
    }

    public TypeArret getType() {
        return type;
    }

    public void setType(TypeArret type) {
        this.type = type;
    }

    public Operation getOperation() {
        return operation;
    }

    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public CauseArret getCause() {
        return cause;
    }

    public void setCause(CauseArret cause) {
        this.cause = cause;
    }
}
