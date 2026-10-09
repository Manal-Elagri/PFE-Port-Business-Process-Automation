package Projet_Stage.PFE.entities;


import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;


@Entity
public class Navire {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nom;
    private String numeroIMO;

    public Navire() {
    }

    public Navire(Long id, String nom, String numeroIMO) {
        this.id = id;
        this.nom = nom;
        this.numeroIMO = numeroIMO;
    }

    public Long getId() {
        return id;
    }

    public String getNom() {
        return nom;
    }

    public String getNumeroIMO() {
        return numeroIMO;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public void setNumeroIMO(String numeroIMO) {
        this.numeroIMO = numeroIMO;
    }
}
