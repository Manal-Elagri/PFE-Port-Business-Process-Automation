package Projet_Stage.PFE.dto;

public class NavireDTO {

    private Long id;
    private String nom;
    private String numeroIMO;

    public NavireDTO() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getNumeroIMO() {
        return numeroIMO;
    }

    public void setNumeroIMO(String numeroIMO) {
        this.numeroIMO = numeroIMO;
    }
}
