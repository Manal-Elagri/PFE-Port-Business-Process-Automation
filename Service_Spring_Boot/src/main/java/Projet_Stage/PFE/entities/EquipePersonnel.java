package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.RolePersonnel;
import jakarta.persistence.*;

@Entity
public class EquipePersonnel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Equipe equipe;

    @ManyToOne
    private Personnel personnel;

    @Enumerated(EnumType.STRING)
    private RolePersonnel roleMetier;


    public EquipePersonnel() {
    }

    public EquipePersonnel(Long id, Equipe equipe, Personnel personnel, RolePersonnel roleMetier) {
        this.id = id;
        this.equipe = equipe;
        this.personnel = personnel;
        this.roleMetier = roleMetier;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Equipe getEquipe() {
        return equipe;
    }

    public void setEquipe(Equipe equipe) {
        this.equipe = equipe;
    }

    public Personnel getPersonnel() {
        return personnel;
    }

    public void setPersonnel(Personnel personnel) {
        this.personnel = personnel;
    }

    public RolePersonnel getRoleMetier() {
        return roleMetier;
    }

    public void setRoleMetier(RolePersonnel roleMetier) {
        this.roleMetier = roleMetier;
    }
}
