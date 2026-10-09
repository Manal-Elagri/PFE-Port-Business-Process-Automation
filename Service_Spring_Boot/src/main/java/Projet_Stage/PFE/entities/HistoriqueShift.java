package Projet_Stage.PFE.entities;


import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class HistoriqueShift {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // équipe concernée
    @ManyToOne
    private Equipe equipe;

    // shift concerné
    @ManyToOne
    private Shift shift;

    // chef qui a fait l'affectation
    @ManyToOne
    private Personnel chefEscale;

    // début réel
    private LocalDateTime dateDebut;

    // fin réelle
    private LocalDateTime dateFin;

    // active ou terminée
    private Boolean active;

    public HistoriqueShift() {
    }

    public HistoriqueShift(Long id, Equipe equipe, Shift shift, Personnel chefEscale, LocalDateTime dateDebut, LocalDateTime dateFin, Boolean active) {
        this.id = id;
        this.equipe = equipe;
        this.shift = shift;
        this.chefEscale = chefEscale;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
        this.active = active;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Shift getShift() {
        return shift;
    }

    public void setShift(Shift shift) {
        this.shift = shift;
    }

    public Equipe getEquipe() {
        return equipe;
    }

    public void setEquipe(Equipe equipe) {
        this.equipe = equipe;
    }

    public Personnel getChefEscale() {
        return chefEscale;
    }

    public void setChefEscale(Personnel chefEscale) {
        this.chefEscale = chefEscale;
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

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }
}
