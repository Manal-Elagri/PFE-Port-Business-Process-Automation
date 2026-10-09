package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.EtatEngin;
import jakarta.persistence.*;

@Entity
public class Engin {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String type;

    @Enumerated(EnumType.STRING)
    private EtatEngin etat;

    private Double capacite;

    public Engin() {
    }

    public Engin(Long id, String type, EtatEngin etat, Double capacite) {
        this.id = id;
        this.type = type;
        this.etat = etat;
        this.capacite = capacite;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public EtatEngin getEtat() {
        return etat;
    }

    public void setEtat(EtatEngin etat) {
        this.etat = etat;
    }

    public Double getCapacite() {
        return capacite;
    }

    public void setCapacite(Double capacite) {
        this.capacite = capacite;
    }
}
