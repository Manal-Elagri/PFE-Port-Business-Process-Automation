package Projet_Stage.PFE.dto.response;

import java.time.LocalDateTime;

public class ScanResponseDTO {

    private Long id;
    private String matricule;
    private String typeIso;
    private Double score;
    private String statut;
    private LocalDateTime date;

    public ScanResponseDTO() {}

    public ScanResponseDTO(Long id,
                           String matricule,
                           String typeIso,
                           Double score,
                           String statut,
                           LocalDateTime date) {
        this.id = id;
        this.matricule = matricule;
        this.typeIso = typeIso;
        this.score = score;
        this.statut = statut;
        this.date = date;
    }

    public Long getId() { return id; }
    public String getMatricule() { return matricule; }
    public String getTypeIso() { return typeIso; }
    public Double getScore() { return score; }
    public String getStatut() { return statut; }
    public LocalDateTime getDate() { return date; }

    public void setId(Long id) { this.id = id; }
    public void setMatricule(String matricule) { this.matricule = matricule; }
    public void setTypeIso(String typeIso) { this.typeIso = typeIso; }
    public void setScore(Double score) { this.score = score; }
    public void setStatut(String statut) { this.statut = statut; }
    public void setDate(LocalDateTime date) { this.date = date; }
}
