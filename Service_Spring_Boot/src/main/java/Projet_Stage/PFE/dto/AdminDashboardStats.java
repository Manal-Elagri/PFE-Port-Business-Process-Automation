package Projet_Stage.PFE.dto;

public record AdminDashboardStats(Long totalPersonnels,
                                  Long totalChefsEscales,
                                  Long totalChefsService,
                                  Long totalChefsDivision,
                                  Long totalEquipes,
                                  Long totalShifts,
                                  Long shiftsActifs,
                                  Long demandesEnAttente,
                                  Long employesEnConge) {}
