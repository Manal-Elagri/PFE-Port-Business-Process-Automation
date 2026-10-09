package Projet_Stage.PFE.dto;

import java.time.LocalDateTime;
import java.util.List;

public class OperationDocumentDTO {

    private Long id;
    private String type;
    private String statut;
    private LocalDateTime dateDebut;
    private LocalDateTime dateFin;

    private Integer nombreConteneurs;

    private String escale;
    private String shift;
    private String poste;
    private String portier;
    private String equipe;

    private List<ConteneurDTO> conteneurs;

    private List<ArretDTO> arrets;
    private List<EnginDTO> engins;
    private List<ChefSignatureDTO> chefs;
    public OperationDocumentDTO() {}


    public OperationDocumentDTO(Long id, String type, String statut, LocalDateTime dateDebut, LocalDateTime dateFin, Integer nombreConteneurs, String escale, String shift, String poste, String portier, String equipe, List<ConteneurDTO> conteneurs, List<ArretDTO> arrets, List<EnginDTO> engins, List<ChefSignatureDTO> chefs) {
        this.id = id;
        this.type = type;
        this.statut = statut;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
        this.nombreConteneurs = nombreConteneurs;
        this.escale = escale;
        this.shift = shift;
        this.poste = poste;
        this.portier = portier;
        this.equipe = equipe;
        this.conteneurs = conteneurs;
        this.arrets = arrets;
        this.engins = engins;
        this.chefs = chefs;
    }

    // getters
    public Long getId() { return id; }
    public String getType() { return type; }
    public String getStatut() { return statut; }
    public LocalDateTime getDateDebut() { return dateDebut; }
    public LocalDateTime getDateFin() { return dateFin; }
    public Integer getNombreConteneurs() { return nombreConteneurs; }
    public String getEscale() { return escale; }
    public String getShift() { return shift; }
    public String getPoste() { return poste; }
    public List<ArretDTO> getArrets() { return arrets; }
    public List<EnginDTO> getEngins() { return engins; }

    public String getPortier() {
        return portier;
    }

    public void setPortier(String portier) {
        this.portier = portier;
    }

    public String getEquipe() {
        return equipe;
    }

    public void setEquipe(String equipe) {
        this.equipe = equipe;
    }

    public List<ConteneurDTO> getConteneurs() {
        return conteneurs;
    }

    public void setConteneurs(List<ConteneurDTO> conteneurs) {
        this.conteneurs = conteneurs;
    }

    public List<ChefSignatureDTO> getChefs() {
        return chefs;
    }

    public void setChefs(List<ChefSignatureDTO> chefs) {
        this.chefs = chefs;
    }

    // setters
    public void setId(Long id) { this.id = id; }
    public void setType(String type) { this.type = type; }
    public void setStatut(String statut) { this.statut = statut; }
    public void setDateDebut(LocalDateTime dateDebut) { this.dateDebut = dateDebut; }
    public void setDateFin(LocalDateTime dateFin) { this.dateFin = dateFin; }
    public void setNombreConteneurs(Integer nombreConteneurs) { this.nombreConteneurs = nombreConteneurs; }
    public void setEscale(String escale) { this.escale = escale; }
    public void setShift(String shift) { this.shift = shift; }
    public void setPoste(String poste) { this.poste = poste; }
    public void setArrets(List<ArretDTO> arrets) { this.arrets = arrets; }
    public void setEngins(List<EnginDTO> engins) { this.engins = engins; }
}
