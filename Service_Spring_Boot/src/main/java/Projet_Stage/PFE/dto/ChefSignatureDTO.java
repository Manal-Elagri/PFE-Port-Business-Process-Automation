package Projet_Stage.PFE.dto;

public class ChefSignatureDTO {

    private String nomComplet;
    private String role;

    public ChefSignatureDTO(String nomComplet, String role) {
        this.nomComplet = nomComplet;
        this.role = role;
    }

    public String getNomComplet() {
        return nomComplet;
    }

    public String getRole() {
        return role;
    }

}
