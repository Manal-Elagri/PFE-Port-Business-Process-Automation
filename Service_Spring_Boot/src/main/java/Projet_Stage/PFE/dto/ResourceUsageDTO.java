package Projet_Stage.PFE.dto;

public class ResourceUsageDTO {

    private String nom;
    private Long totalUtilisations;

    public ResourceUsageDTO(String nom, Long totalUtilisations) {
        this.nom = nom;
        this.totalUtilisations = totalUtilisations;
    }

    public String getNom() {
        return nom;
    }

    public Long getTotalUtilisations() {
        return totalUtilisations;
    }

}
