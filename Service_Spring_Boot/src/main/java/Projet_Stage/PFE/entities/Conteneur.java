package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.StatutConteneur;
import jakarta.persistence.*;

@Entity
public class Conteneur {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String matricule;

    private String typeIso;

    @Enumerated(EnumType.STRING)
    private StatutConteneur statut;

    public Conteneur() {
    }

    public Conteneur(Long id, String matricule, String typeIso, StatutConteneur statut) {
        this.id = id;
        this.matricule = matricule;
        this.typeIso = typeIso;
        this.statut = statut;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getMatricule() {
        return matricule;
    }

    public void setMatricule(String matricule) {
        this.matricule = matricule;
    }

    public String getTypeIso() {
        return typeIso;
    }

    public void setTypeIso(String typeIso) {
        this.typeIso = typeIso;
    }

    public StatutConteneur getStatut() {
        return statut;
    }

    public void setStatut(StatutConteneur statut) {
        this.statut = statut;
    }
}
