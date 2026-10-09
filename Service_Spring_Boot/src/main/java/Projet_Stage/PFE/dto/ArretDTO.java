package Projet_Stage.PFE.dto;

import java.time.LocalDateTime;

public class ArretDTO {

    private Long id;
    private String type;
    private LocalDateTime dateDebut;
    private LocalDateTime dateFin;
    private String cause;

    public ArretDTO() {}

    public ArretDTO(Long id, String type, LocalDateTime dateDebut, LocalDateTime dateFin, String cause) {
        this.id = id;
        this.type = type;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
        this.cause = cause;
    }

    public Long getId() { return id; }
    public String getType() { return type; }
    public LocalDateTime getDateDebut() { return dateDebut; }
    public LocalDateTime getDateFin() { return dateFin; }
    public String getCause() { return cause; }

    public void setId(Long id) { this.id = id; }
    public void setType(String type) { this.type = type; }
    public void setDateDebut(LocalDateTime dateDebut) { this.dateDebut = dateDebut; }
    public void setDateFin(LocalDateTime dateFin) { this.dateFin = dateFin; }
    public void setCause(String cause) { this.cause = cause; }
}
