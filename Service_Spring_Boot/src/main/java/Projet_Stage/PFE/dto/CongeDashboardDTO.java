package Projet_Stage.PFE.dto;

public record CongeDashboardDTO(long absentToday,

                                long demandesEnAttente,
                                long demandesAcceptees,
                                long demandesRefusees,

                                long congesAnnuels,
                                long congesMaladie,
                                long congesSansSolde,

                                long chefsEscalesAbsents,
                                long chefsEquipesAbsents,
                                long employesAbsents) {}
