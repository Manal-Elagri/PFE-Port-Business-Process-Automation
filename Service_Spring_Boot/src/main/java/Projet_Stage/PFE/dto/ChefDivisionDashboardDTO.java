package Projet_Stage.PFE.dto;

public record ChefDivisionDashboardDTO(

        // Performance globale
        long operationsToday,
        long operationsWeek,

        long chargements,
        long dechargements,

        // Qualité
        Double tauxAnnulation,
        Double tauxRetard,
        Double tauxArret,

        // IA / Scan
        Double tauxDetectionIA,
        long scansToday,
        long scansWeek,
        long erreursIA,

        // Documents
        long documentsEnAttente,
        long documentsSignes

) {}