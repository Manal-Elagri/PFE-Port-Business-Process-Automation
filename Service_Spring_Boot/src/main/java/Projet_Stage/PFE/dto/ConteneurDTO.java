package Projet_Stage.PFE.dto;

public class ConteneurDTO {

    private String matricule;
    private String typeIso;

    public ConteneurDTO(String matricule, String typeIso) {
        this.matricule = matricule;
        this.typeIso = typeIso;
    }

    public String getMatricule() { return matricule; }
    public String getTypeIso() { return typeIso; }
}
