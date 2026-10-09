package Projet_Stage.PFE.dto;

public class StatsRateDTO {

    private String label;
    private Double value;

    public StatsRateDTO(String label, Double value) {
        this.label = label;
        this.value = value;
    }

    public String getLabel() {
        return label;
    }

    public Double getValue() {
        return value;
    }

}
