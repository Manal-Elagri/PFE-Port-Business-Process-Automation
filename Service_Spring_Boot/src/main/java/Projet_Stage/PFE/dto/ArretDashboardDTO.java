package Projet_Stage.PFE.dto;

import java.util.List;

public record ArretDashboardDTO(

        long totalArrets,
        long arretsToday,
        long arretsWeek,

        long tempsPerduTotal,
        double avgDuration,

        double tauxBlocageOperations,

        List<ArretStatsDTO> topCauses

) {}
