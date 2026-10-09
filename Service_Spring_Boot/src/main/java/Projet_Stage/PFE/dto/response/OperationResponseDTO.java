package Projet_Stage.PFE.dto.response;

import java.time.LocalDateTime;

public class OperationResponseDTO {

    private Long id;
    private String statut;
    private LocalDateTime dateDebut;
    private Integer nombreConteneurs;

    public OperationResponseDTO() {
    }

    public OperationResponseDTO(Long id, String statut, LocalDateTime dateDebut, Integer nombreConteneurs) {
        this.id = id;
        this.statut = statut;
        this.dateDebut = dateDebut;
        this.nombreConteneurs = nombreConteneurs;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public LocalDateTime getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(LocalDateTime dateDebut) {
        this.dateDebut = dateDebut;
    }

    public Integer getNombreConteneurs() {
        return nombreConteneurs;
    }

    public void setNombreConteneurs(Integer nombreConteneurs) {
        this.nombreConteneurs = nombreConteneurs;
    }
}
