package Projet_Stage.PFE.dto;

public class CauseArretDTO {

    private Long id;
    private String libelle;
    private String description;

    public CauseArretDTO() {}

    public CauseArretDTO(Long id, String libelle, String description) {
        this.id = id;
        this.libelle = libelle;
        this.description = description;
    }

    public Long getId() { return id; }
    public String getLibelle() { return libelle; }
    public String getDescription() { return description; }

    public void setId(Long id) { this.id = id; }
    public void setLibelle(String libelle) { this.libelle = libelle; }
    public void setDescription(String description) { this.description = description; }
}
