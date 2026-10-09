package Projet_Stage.PFE.dto;

public record ChefEquipeDashboardDTO(// équipe
                                     String equipeCode,
                                     long totalMembres,

                                     // opérations
                                     long operationsEnCours,
                                     long operationsTerminees,
                                     long totalOperations,

                                     // performance
                                     long totalConteneurs,
                                     Double moyenneConteneurs,

                                     Double moyenneDureeOperation,
                                     Double tauxReussite,

                                     // incidents
                                     long totalArrets,
                                     long tempsPerdu,

                                     // scan
                                     long scansToday,
                                     Double tauxDetection,

                                     // documents
                                     long documentsEnAttente,
                                     long documentsSignes
) {
}
