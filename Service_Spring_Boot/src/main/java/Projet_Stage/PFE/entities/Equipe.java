package Projet_Stage.PFE.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

import java.util.List;

@Entity
public class Equipe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String matriculeEquipe;

    @ManyToOne
    private Personnel chefEquipe;

    @ManyToOne
    @JoinColumn(name = "shift_id")
    @JsonIgnore                        // ✅ déjà fait
    private Shift shift;

    @ManyToOne
    @JoinColumn(name = "chef_escale_id")
    @JsonIgnore                        // ✅ déjà fait
    private Personnel chefEscale;

    @ManyToOne
    @JsonIgnore                        // ✅ AJOUTE CECI — casse Equipe → planningJour → shifts → Equipe
    private PlanningJour planningJour;

    @OneToMany(mappedBy = "equipe")
    @JsonIgnore                        // ✅ AJOUTE CECI — casse Equipe → equipePersonnels → Equipe
    private List<EquipePersonnel> equipePersonnels;

    public Equipe() {}

    public Equipe(Long id, String matriculeEquipe, Personnel chefEquipe, Shift shift, Personnel chefEscale, PlanningJour planningJour) {
        this.id = id;
        this.matriculeEquipe = matriculeEquipe;
        this.chefEquipe = chefEquipe;
        this.shift = shift;
        this.chefEscale = chefEscale;
        this.planningJour = planningJour;
    }

    public List<EquipePersonnel> getEquipePersonnels() {
        return equipePersonnels;
    }

    public void setEquipePersonnels(List<EquipePersonnel> equipePersonnels) {
        this.equipePersonnels = equipePersonnels;
    }

    public Personnel getChefEscale() {
        return chefEscale;
    }

    public void setChefEscale(Personnel chefEscale) {
        this.chefEscale = chefEscale;
    }

    public PlanningJour getPlanningJour() {
        return planningJour;
    }

    public void setPlanningJour(PlanningJour planningJour) {
        this.planningJour = planningJour;
    }

    public Personnel getChefEquipe() {
        return chefEquipe;
    }

    public void setChefEquipe(Personnel chefEquipe) {
        this.chefEquipe = chefEquipe;
    }

    public Shift getShift() {
        return shift;
    }

    public void setShift(Shift shift) {
        this.shift = shift;
    }


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getMatriculeEquipe() {
        return matriculeEquipe;
    }

    public void setMatriculeEquipe(String matriculeEquipe) {
        this.matriculeEquipe = matriculeEquipe;
    }
}
