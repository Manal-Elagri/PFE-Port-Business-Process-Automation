package Projet_Stage.PFE.dto;

public class EnginDTO {

    private Long id;
    private String type;
    private Double capacite;
    private String etat;

    public EnginDTO() {}

    public EnginDTO(Long id, String type, Double capacite) {
        this.id = id;
        this.type = type;
        this.capacite = capacite;
    }

    public Long getId() { return id; }
    public String getType() { return type; }
    public Double getCapacite() { return capacite; }

    public void setId(Long id) { this.id = id; }
    public void setType(String type) { this.type = type; }
    public void setCapacite(Double capacite) { this.capacite = capacite; }


}
