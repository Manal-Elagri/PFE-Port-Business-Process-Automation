package Projet_Stage.PFE.dto;

public class StatsCountDTO {

    private String label;
    private Long total;

    public StatsCountDTO(String label, Long total) {
        this.label = label;
        this.total = total;
    }

    public String getLabel() {
        return label;
    }

    public Long getTotal() {
        return total;
    }
}
