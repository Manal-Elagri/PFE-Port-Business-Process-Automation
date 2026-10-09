package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.TypeShift;
import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.time.LocalTime;
import java.util.List;

@Entity
public class Shift {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private TypeShift type;

    private LocalTime heureDebut;
    private LocalTime heureFin;

    // 👇 un shift contient plusieurs équipes
    @OneToMany(mappedBy = "shift")
    @JsonIgnore
    private List<Equipe> equipes;

    // shift appartient à un jour
    @ManyToOne
    @JsonIgnore
    private PlanningJour planningJour;


    @ManyToOne
    private Personnel chefService;

    @ManyToOne
    private Personnel chefDivision;

    public Shift() {
    }

    public Shift(Long id, TypeShift type, LocalTime heureDebut, LocalTime heureFin, List<Equipe> equipes) {
        this.id = id;
        this.type = type;
        this.heureDebut = heureDebut;
        this.heureFin = heureFin;
        this.equipes = equipes;
    }

    public List<Equipe> getEquipes() {
        return equipes;
    }

    public void setEquipes(List<Equipe> equipes) {
        this.equipes = equipes;
    }

    public Long getId() {
        return id;
    }

    public TypeShift getType() {
        return type;
    }

    public void setType(TypeShift type) {
        this.type = type;
    }

    public LocalTime getHeureDebut() {
        return heureDebut;
    }

    public LocalTime getHeureFin() {
        return heureFin;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public PlanningJour getPlanningJour() {
        return planningJour;
    }

    public void setPlanningJour(PlanningJour planningJour) {
        this.planningJour = planningJour;
    }

    public void setHeureDebut(LocalTime heureDebut) {
        this.heureDebut = heureDebut;
    }

    public void setHeureFin(LocalTime heureFin) {
        this.heureFin = heureFin;
    }

    public Personnel getChefService() {
        return chefService;
    }

    public void setChefService(Personnel chefService) {
        this.chefService = chefService;
    }

    public Personnel getChefDivision() {
        return chefDivision;
    }

    public void setChefDivision(Personnel chefDivision) {
        this.chefDivision = chefDivision;
    }
}
