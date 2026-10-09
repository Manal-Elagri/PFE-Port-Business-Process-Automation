package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.StatutOperation;
import Projet_Stage.PFE.enums.TypeOperation;
import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
public class Operation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Enumerated(EnumType.STRING)
    private TypeOperation type;

    @Enumerated(EnumType.STRING)
    private StatutOperation statut;

    private Integer nombreConteneurs;

    private LocalDateTime dateDebut;
    private LocalDateTime dateFin;

    @ManyToOne private Escale escale;
    @ManyToOne private Shift shift;
    @ManyToOne private Poste poste;
    @ManyToOne private Portier portier;
    @ManyToOne private Equipe equipe;

    @OneToMany(mappedBy = "operation")
    private List<Arret> arrets;
    @OneToMany(mappedBy = "operation")
    private List<OperationEngin> operationEngins;

    @OneToMany(mappedBy = "operation")
    private List<OperationResponsable> operationResponsables;
    public Operation() {
    }

    public Operation(Long id, TypeOperation type, StatutOperation statut, Integer nombreConteneurs, LocalDateTime dateDebut, LocalDateTime dateFin, Escale escale, Shift shift, Poste poste, Portier portier, Equipe equipe, List<Arret> arrets, List<OperationEngin> operationEngins) {
        this.id = id;
        this.type = type;
        this.statut = statut;
        this.nombreConteneurs = nombreConteneurs;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
        this.escale = escale;
        this.shift = shift;
        this.poste = poste;
        this.portier = portier;
        this.equipe = equipe;
        this.arrets = arrets;
        this.operationEngins = operationEngins;
    }

    public List<OperationEngin> getOperationEngins() {
        return operationEngins;
    }

    public void setOperationEngins(List<OperationEngin> operationEngins) {
        this.operationEngins = operationEngins;
    }

    public List<Arret> getArrets() {
        return arrets;
    }

    public void setArrets(List<Arret> arrets) {
        this.arrets = arrets;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public TypeOperation getType() {
        return type;
    }

    public void setType(TypeOperation type) {
        this.type = type;
    }

    public StatutOperation getStatut() {
        return statut;
    }

    public void setStatut(StatutOperation statut) {
        this.statut = statut;
    }

    public Integer getNombreConteneurs() {
        return nombreConteneurs;
    }

    public void setNombreConteneurs(Integer nombreConteneurs) {
        this.nombreConteneurs = nombreConteneurs;
    }

    public LocalDateTime getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(LocalDateTime dateDebut) {
        this.dateDebut = dateDebut;
    }

    public LocalDateTime getDateFin() {
        return dateFin;
    }

    public void setDateFin(LocalDateTime dateFin) {
        this.dateFin = dateFin;
    }

    public Escale getEscale() {
        return escale;
    }

    public void setEscale(Escale escale) {
        this.escale = escale;
    }

    public Shift getShift() {
        return shift;
    }

    public void setShift(Shift shift) {
        this.shift = shift;
    }

    public Poste getPoste() {
        return poste;
    }

    public void setPoste(Poste poste) {
        this.poste = poste;
    }

    public Portier getPortier() {
        return portier;
    }

    public void setPortier(Portier portier) {
        this.portier = portier;
    }

    public Equipe getEquipe() {
        return equipe;
    }

    public void setEquipe(Equipe equipe) {
        this.equipe = equipe;
    }

    public List<OperationResponsable> getOperationResponsables() {
        return operationResponsables;
    }

    public void setOperationResponsables(List<OperationResponsable> operationResponsables) {
        this.operationResponsables = operationResponsables;
    }
}
