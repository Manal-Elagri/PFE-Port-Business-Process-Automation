package Projet_Stage.PFE.service;

import Projet_Stage.PFE.dto.*;
import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.enums.*;
import Projet_Stage.PFE.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChefServiceDashboardService {

    private final OperationRepository operationRepository;
    private final ArretRepository arretRepository;
    private final ScanRepository scanRepository;
    private final ShiftRepository shiftRepository;
    private final SignatureRepository signatureRepository;
    private final CongesRepository congesRepository;
    private  final HistoriqueShiftRepository historiqueShiftRepository;
    private final EquipeRepository equipeRepository;

    private Personnel  getChefServiceConnecte() {

        User user = getCurrentUser();

        if (!RoleUser.CHEF_SERVICE.equals(user.getRole())) {
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

    public ChefServiceDashboardDTO getStats(
            Long shiftId
    ) {

        Personnel chefService =
                getChefServiceConnecte();

        long documentsEnAttente =
                signatureRepository
                        .countBySignataireIdAndStatut(
                                chefService.getId(),
                                StatutSignature.EN_ATTENTE
                        );

        long documentsSignes =
                signatureRepository
                        .countBySignataireIdAndStatut(
                                chefService.getId(),
                                StatutSignature.SIGNE
                        );

        return new ChefServiceDashboardDTO(

                // A. Production
                operationRepository.countByShiftId(shiftId),

                operationRepository.countByShiftIdAndStatut(
                        shiftId,
                        StatutOperation.EN_COURS
                ),

                operationRepository.countByShiftIdAndStatut(
                        shiftId,
                        StatutOperation.TERMINE
                ),

                operationRepository.countByShiftIdAndStatut(
                        shiftId,
                        StatutOperation.PAUSE
                ),

                // B. Ressources
                operationRepository.countUsedPostes(shiftId),

                operationRepository.countUsedPortiers(shiftId),

                operationRepository.countUsedEngins(shiftId),

                // C. Performance
                operationRepository.totalContainers(shiftId),

                operationRepository.avgContainers(shiftId),

                operationRepository.avgDuration(shiftId),

                // D. Blocages
                arretRepository.countByShift(shiftId),

                arretRepository.totalArretDuration(shiftId),

                // E. IA
                scanRepository.detectionRate(),

                scanRepository.countByDateAfter(
                        LocalDateTime.now().minusDays(1)
                ),

                // F. Documents
                documentsEnAttente,

                documentsSignes

        );
    }

    public List<Signature> getMySignatureHistory() {

        Personnel chefService =
                getChefServiceConnecte();

        return signatureRepository
                .findBySignataireIdOrderByDateSignatureDesc(
                        chefService.getId()
                );
    }


    public CongeDashboardDTO getCongeDashboard() {

        getChefServiceConnecte();

        LocalDate today =
                LocalDate.now();

        return new CongeDashboardDTO(

                // absents aujourd'hui
                congesRepository
                        .countByDateDebutLessThanEqualAndDateFinGreaterThanEqualAndStatut(
                                today,
                                today,
                                Conges.StatutConge.ACCEPTE
                        ),

                // demandes
                congesRepository.countByStatut(
                        Conges.StatutConge.EN_ATTENTE
                ),

                congesRepository.countByStatut(
                        Conges.StatutConge.ACCEPTE
                ),

                congesRepository.countByStatut(
                        Conges.StatutConge.REFUSE
                ),

                // types
                congesRepository.countByType(
                        Conges.TypeCong.ANNUEL
                ),

                congesRepository.countByType(
                        Conges.TypeCong.MALADIE
                ),

                congesRepository.countByType(
                        Conges.TypeCong.SANS_SOLDE
                ),

                // rôles
                congesRepository.countAbsentByRole(
                        today,
                        RoleUser.CHEF_ESCALE
                ),

                congesRepository.countAbsentByRole(
                        today,
                        RoleUser.CHEF_EQUIPE
                ),

                congesRepository.countAbsentByRole(
                        today,
                        RoleUser.EMPLOYE
                )

        );
    }

    public List<Shift> getShiftCalendar(LocalDate date) {

        getChefServiceConnecte();

        return shiftRepository.findByPlanningJour_Date(date);
    }

    public List<HistoriqueShift> getShiftWorkHistory(Long shiftId) {

        getChefServiceConnecte();

        return historiqueShiftRepository
                .findByShiftIdOrderByDateDebutDesc(shiftId);
    }

    public List<Equipe> getEquipesByShift(Long shiftId) {

        getChefServiceConnecte();

        return equipeRepository.findByShiftId(shiftId);
    }

    public List<Equipe> getActiveTeamsToday() {

        getChefServiceConnecte();

        return equipeRepository.findActiveTeamsToday(LocalDate.now());
    }
}