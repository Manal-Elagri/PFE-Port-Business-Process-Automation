package Projet_Stage.PFE.dto;

public record ChefServiceDashboardDTO( long totalOperations,
                                       long operationsEnCours,
                                       long operationsTerminees,
                                       long operationsAnnulees,

                                       long postesUtilises,
                                       long portiersUtilises,
                                       long enginsUtilises,

                                       long totalConteneurs,
                                       Double moyenneConteneurs,
                                       Double dureeMoyenneMinutes,

                                       long totalArrets,
                                       Double dureeTotaleArretsMinutes,

                                       Double tauxDetectionIA,
                                       long scansToday,

                                       long documentsEnAttente,
                                       long documentsSignes) {}
