package Projet_Stage.PFE.entities;


import Projet_Stage.PFE.enums.RolePersonnel;
import Projet_Stage.PFE.enums.StatutSignature;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class OperationResponsable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private RolePersonnel role;

    private Integer ordreSignature;

    @Enumerated(EnumType.STRING)
    private StatutSignature statut;

    private LocalDateTime dateSignature;

    @ManyToOne private Operation operation;
    @ManyToOne private Personnel personnel;

    public OperationResponsable() {
    }

    public OperationResponsable(Long id, RolePersonnel role, Integer ordreSignature, StatutSignature statut, LocalDateTime dateSignature, Operation operation, Personnel personnel) {
        this.id = id;
        this.role = role;
        this.ordreSignature = ordreSignature;
        this.statut = statut;
        this.dateSignature = dateSignature;
        this.operation = operation;
        this.personnel = personnel;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public RolePersonnel getRole() {
        return role;
    }

    public void setRole(RolePersonnel role) {
        this.role = role;
    }

    public Integer getOrdreSignature() {
        return ordreSignature;
    }

    public void setOrdreSignature(Integer ordreSignature) {
        this.ordreSignature = ordreSignature;
    }

    public StatutSignature getStatut() {
        return statut;
    }

    public void setStatut(StatutSignature statut) {
        this.statut = statut;
    }

    public LocalDateTime getDateSignature() {
        return dateSignature;
    }

    public void setDateSignature(LocalDateTime dateSignature) {
        this.dateSignature = dateSignature;
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
