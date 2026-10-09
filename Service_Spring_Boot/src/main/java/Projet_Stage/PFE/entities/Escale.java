package Projet_Stage.PFE.entities;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
public class Escale {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String numeroEscale;

    private LocalDate dateArrivee;
    private LocalDate dateDepart;

    @ManyToOne
    private Navire navire;

    public Escale() {
    }

    public Escale(Long id, String numeroEscale, LocalDate dateArrivee, LocalDate dateDepart, Navire navire) {
        this.id = id;
        this.numeroEscale = numeroEscale;
        this.dateArrivee = dateArrivee;
        this.dateDepart = dateDepart;
        this.navire = navire;
    }

    public Long getId() {
        return id;
    }

    public String getNumeroEscale() {
        return numeroEscale;
    }

    public LocalDate getDateArrivee() {
        return dateArrivee;
    }

    public LocalDate getDateDepart() {
        return dateDepart;
    }

    public Navire getNavire() {
        return navire;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setNumeroEscale(String numeroEscale) {
        this.numeroEscale = numeroEscale;
    }

    public void setDateArrivee(LocalDate dateArrivee) {
        this.dateArrivee = dateArrivee;
    }

    public void setDateDepart(LocalDate dateDepart) {
        this.dateDepart = dateDepart;
    }

    public void setNavire(Navire navire) {
        this.navire = navire;
    }
}
