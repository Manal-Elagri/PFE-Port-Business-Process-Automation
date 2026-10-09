package Projet_Stage.PFE.service;

import Projet_Stage.PFE.dto.ChefEquipeDashboardDTO;
import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.enums.RoleUser;
import Projet_Stage.PFE.enums.StatutOperation;
import Projet_Stage.PFE.enums.StatutSignature;
import Projet_Stage.PFE.repository.CongesRepository;
import Projet_Stage.PFE.repository.EquipePersonnelRepository;
import Projet_Stage.PFE.repository.HistoriqueShiftRepository;
import Projet_Stage.PFE.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChefDEquipeService {

    private final EquipePersonnelRepository equipePersonnelRepository;
    private final HistoriqueShiftRepository historiqueShiftRepository;
    private final CongesRepository congesRepository;
    private final OperationRepository operationRepository;
    private final ArretRepository arretRepository;
    private final ScanRepository scanRepository;
    private final SignatureRepository signatureRepository;
    private final EquipeRepository equipeRepository;

    // =====================================================
    // Employé CONNECTÉ
    // =====================================================
    private Personnel  getChefEquipeConnecte() {

        User user = getCurrentUser();

        if (!RoleUser.CHEF_EQUIPE.equals(user.getRole())) {
            throw new RuntimeException("Accès refusé");
        }

        return user.getPersonnel();
    }

    public User getCurrentUser() {
        Object principal = SecurityContextHolder
                .getContext()
                .getAuthentication()
                .getPrincipal();

        if (principal instanceof User user) {
            return user;
        }

        throw new RuntimeException("Utilisateur non authentifié");
    }
    /// ==================== Gestion Des congés Pour Tout Le personnel ==================

    private Conges getMyConge(Long congeId) {

        Personnel chef =
                getChefEquipeConnecte();

        Conges conge =
                congesRepository
                        .findById(congeId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Congé introuvable"
                                ));

        if (!conge.getEmploye()
                .getId()
                .equals(chef.getId())) {

            throw new RuntimeException(
                    "Accès refusé"
            );
        }

        return conge;
    }
    public List<Conges> getMyConges() {

        Personnel chef =
                getChefEquipeConnecte();

        return congesRepository
                .findByEmployeId(
                        chef.getId()
                );
    }

    public List<Conges> getMyCongeHistory() {

        Personnel chef =
                getChefEquipeConnecte();

        return congesRepository
                .findByEmployeIdOrderByDateDebutDesc(
                        chef.getId()
                );
    }
    /**
     * 📝 Demander un congé
     */
    public Conges demanderConge(LocalDate dateDebut,
                                LocalDate dateFin,
                                Conges.TypeCong type) {
        Personnel chef = getChefEquipeConnecte();

        Conges conge = new Conges();
        conge.setEmploye(chef);
        conge.setDateDebut(dateDebut);
        conge.setDateFin(dateFin);
        conge.setStatut(Conges.StatutConge.EN_ATTENTE);
        conge.setType(type);
        return congesRepository.save(conge);
    }

    /**
     * ✏️ Modifier une demande de congé (si EN_ATTENTE)
     */
    public Conges modifierDemandeConge(
            Long congeId,
            LocalDate newDateDebut,
            LocalDate newDateFin,
            Conges.TypeCong type
    ) {

        Conges conge =
                getMyConge(congeId);

        if (conge.getStatut()
                != Conges.StatutConge.EN_ATTENTE) {

            throw new RuntimeException(
                    "Impossible de modifier une demande déjà traitée"
            );
        }

        if (newDateDebut.isAfter(newDateFin)) {

            throw new RuntimeException(
                    "Date invalide"
            );
        }

        if (conge.getDateDebut()
                .isBefore(LocalDate.now())) {

            throw new RuntimeException(
                    "Ce congé a déjà commencé"
            );
        }

        conge.setDateDebut(newDateDebut);
        conge.setDateFin(newDateFin);
        conge.setType(type);

        return congesRepository.save(conge);
    }

    /**
     * ❌ Supprimer une demande de congé (si EN_ATTENTE)
     */
    public boolean supprimerDemandeConge(
            Long congeId
    ) {

        Conges conge =
                getMyConge(congeId);

        if (conge.getStatut()
                != Conges.StatutConge.EN_ATTENTE) {

            throw new RuntimeException(
                    "Impossible de supprimer une demande déjà traitée"
            );
        }

        if (conge.getDateDebut()
                .isBefore(LocalDate.now())) {

            throw new RuntimeException(
                    "Ce congé a déjà commencé"
            );
        }

        congesRepository.delete(conge);

        return true;
    }

    /**
     * 📋 Récupérer les congés d’un employé
     */

    public List<Conges> getAbsentMembersTodayDetails() {

        Personnel chef =
                getChefEquipeConnecte();

        Equipe equipe =
                equipeRepository
                        .findByChefEquipeId(
                                chef.getId()
                        )
                        .orElseThrow();

        LocalDate today =
                LocalDate.now();

        return congesRepository
                .findByEmploye_Equipe_IdAndDateDebutLessThanEqualAndDateFinGreaterThanEqualAndStatut(
                        equipe.getId(),
                        today,
                        today,
                        Conges.StatutConge.ACCEPTE
                );
    }
    /// =========== Mes Affectations ===========

    public List<EquipePersonnel> getMyAssignments() {

        Personnel chef = getChefEquipeConnecte();

        return equipePersonnelRepository
                .findByPersonnelId(chef.getId());
    }

    public List<EquipePersonnel> getMyAssignmentsByShift(Long shiftId) {

        Personnel chef = getChefEquipeConnecte();

        return equipePersonnelRepository
                .findByPersonnelIdAndEquipe_Shift_Id(
                        chef.getId(),
                        shiftId
                );
    }

    public List<EquipePersonnel> getMyAssignmentsByEquipe(Long equipeId) {

        Personnel chef = getChefEquipeConnecte();

        return equipePersonnelRepository
                .findByPersonnelIdAndEquipe_Id(
                        chef.getId(),
                        equipeId
                );
    }

    public List<EquipePersonnel> getMyShiftCalendar() {

        Personnel chef = getChefEquipeConnecte();

        return equipePersonnelRepository
                .findByPersonnelId(chef.getId());
    }

    public List<HistoriqueShift> getMyHistory() {

        Personnel chef = getChefEquipeConnecte();

        return historiqueShiftRepository
                .findByPersonnelId(
                        chef.getId()
                );
    }

    public ChefEquipeDashboardDTO getDashboardStats() {

        Personnel chef =
                getChefEquipeConnecte();

        Equipe equipe =
                equipeRepository
                        .findByChefEquipeId(
                                chef.getId()
                        )
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Aucune équipe trouvée"
                                ));

        long documentsEnAttente =
                signatureRepository
                        .countBySignataireIdAndStatut(
                                chef.getId(),
                                StatutSignature.EN_ATTENTE
                        );

        long documentsSignes =
                signatureRepository
                        .countBySignataireIdAndStatut(
                                chef.getId(),
                                StatutSignature.SIGNE
                        );

        return new ChefEquipeDashboardDTO(

                // équipe
                equipe.getMatriculeEquipe(),

                equipePersonnelRepository
                        .countByEquipeId(
                                equipe.getId()
                        ),

                // opérations
                operationRepository
                        .countByEquipeIdAndStatut(
                                equipe.getId(),
                                StatutOperation.EN_COURS
                        ),

                operationRepository
                        .countByEquipeIdAndStatut(
                                equipe.getId(),
                                StatutOperation.TERMINE
                        ),

                operationRepository
                        .countByEquipeId(
                                equipe.getId()
                        ),

                // performance
                operationRepository
                        .totalContainersByEquipe(
                                equipe.getId()
                        ),

                operationRepository
                        .avgContainersByEquipe(
                                equipe.getId()
                        ),
                operationRepository
                        .avgOperationDurationByEquipe(
                                equipe.getId()
                        ),

                operationRepository
                        .successRateByEquipe(
                                equipe.getId()
                        ),
                // incidents
                arretRepository
                        .countByEquipe(
                                equipe.getId()
                        ),

                arretRepository
                        .tempsPerduByEquipe(
                                equipe.getId()
                        ),

                // IA
                scanRepository
                        .countByDateAfter(
                                java.time.LocalDateTime.now()
                                        .minusDays(1)
                        ),

                scanRepository
                        .detectionRate(),

                // docs
                documentsEnAttente,
                documentsSignes

        );
    }

    public Equipe getMyManagedTeam() {

        Personnel chef =
                getChefEquipeConnecte();

        return equipeRepository
                .findByChefEquipeId(
                        chef.getId()
                )
                .orElseThrow(() ->
                        new RuntimeException(
                                "Aucune équipe trouvée"
                        ));
    }

    public long getAbsentMembersToday() {

        Personnel chef =
                getChefEquipeConnecte();

        Equipe equipe =
                equipeRepository
                        .findByChefEquipeId(
                                chef.getId()
                        )
                        .orElseThrow();

        return congesRepository
                .countAbsentByEquipe(
                        equipe.getId(),
                        LocalDate.now(),
                        Conges.StatutConge.ACCEPTE
                );
    }

}
