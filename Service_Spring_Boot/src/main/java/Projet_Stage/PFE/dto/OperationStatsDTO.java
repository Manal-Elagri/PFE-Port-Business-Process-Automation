package Projet_Stage.PFE.dto;

public class OperationStatsDTO {

    private Long totalOperations;

    private Long terminees;

    private Long enCours;

    private Long annulees;

    private Double moyenneConteneurs;

    private Double dureeMoyenneSecondes;

    public OperationStatsDTO(
            Long totalOperations,
            Long terminees,
            Long enCours,
            Long annulees,
            Double moyenneConteneurs,
            Double dureeMoyenneSecondes
    ) {
        this.totalOperations = totalOperations;
        this.terminees = terminees;
        this.enCours = enCours;
        this.annulees = annulees;
        this.moyenneConteneurs = moyenneConteneurs;
        this.dureeMoyenneSecondes = dureeMoyenneSecondes;
    }
}
