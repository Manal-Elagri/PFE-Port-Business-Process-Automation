package Projet_Stage.PFE.dto;

import java.time.LocalDate;

public class EscaleDTO {

    private Long id;
    private String numeroEscale;
    private LocalDate dateArrivee;
    private LocalDate dateDepart;
    private Long navireId;

    public EscaleDTO() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNumeroEscale() {
        return numeroEscale;
    }

    public void setNumeroEscale(String numeroEscale) {
        this.numeroEscale = numeroEscale;
    }

    public LocalDate getDateArrivee() {
        return dateArrivee;
    }

    public void setDateArrivee(LocalDate dateArrivee) {
        this.dateArrivee = dateArrivee;
    }

    public LocalDate getDateDepart() {
        return dateDepart;
    }

    public void setDateDepart(LocalDate dateDepart) {
        this.dateDepart = dateDepart;
    }

    public Long getNavireId() {
        return navireId;
    }

    public void setNavireId(Long navireId) {
        this.navireId = navireId;
    }
}
