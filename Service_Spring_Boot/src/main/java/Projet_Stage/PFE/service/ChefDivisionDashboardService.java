package Projet_Stage.PFE.service;

import Projet_Stage.PFE.dto.*;
import Projet_Stage.PFE.entities.Conges;
import Projet_Stage.PFE.entities.Personnel;
import Projet_Stage.PFE.entities.Signature;
import Projet_Stage.PFE.entities.User;
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
public class ChefDivisionDashboardService {

    private final OperationRepository operationRepository;
    private final ScanRepository scanRepository;
    private final SignatureRepository signatureRepository;
    private final ArretRepository arretRepository;
    private final CongesRepository congesRepository;
    private final OperationEnginRepository operationEnginRepository;

    private Personnel  getChefDivisionConnecte() {

        User user = getCurrentUser();

        if (!RoleUser.CHEF_DIVISION.equals(user.getRole())) {
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

    public ChefDivisionDashboardDTO getStats() {

        Personnel chefDivision =
                getChefDivisionConnecte();

        long totalOperations =
                operationRepository.count();

        long operationsAnnulees =
                operationRepository.countByStatut(
                        StatutOperation.PAUSE
                );

        double tauxAnnulation =
                totalOperations == 0
                        ? 0
                        : ((double) operationsAnnulees * 100)
                        / totalOperations;

        long documentsEnAttente =
                signatureRepository
                        .countBySignataireIdAndStatut(
                                chefDivision.getId(),
                                StatutSignature.EN_ATTENTE
                        );

        long documentsSignes =
                signatureRepository
                        .countBySignataireIdAndStatut(
                                chefDivision.getId(),
                                StatutSignature.SIGNE
                        );

        return new ChefDivisionDashboardDTO(

                // A. Performance globale
                operationRepository.countByDateDebutAfter(
                        LocalDateTime.now().minusDays(1)
                ),

                operationRepository.countByDateDebutAfter(
                        LocalDateTime.now().minusDays(7)
                ),

                operationRepository.countByType(
                        TypeOperation.CHARGEMENT
                ),

                operationRepository.countByType(
                        TypeOperation.DECHARGEMENT
                ),


                // B. Qualité
                tauxAnnulation,

                operationRepository.calculateRetardRate(),

                arretRepository.calculateArretRate(),

                // C. Scan IA
                scanRepository.detectionRate(),

                scanRepository.countByDateAfter(
                        LocalDateTime.now().minusDays(1)
                ),

                scanRepository.countByDateAfter(
                        LocalDateTime.now().minusDays(7)
                ),

                scanRepository.countErrors(),

                // D. Documents
                documentsEnAttente,

                documentsSignes

        );
    }

    public List<Signature> getMySignatureHistory() {

        Personnel chefDivision =
                getChefDivisionConnecte();

        return signatureRepository
                .findBySignataireIdOrderByDateSignatureDesc(
                        chefDivision.getId()
                );
    }

    public CongeDashboardDTO getCongeDashboard() {

        getChefDivisionConnecte();

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

                // types de congés
                congesRepository.countByType(
                        Conges.TypeCong.ANNUEL
                ),

                congesRepository.countByType(
                        Conges.TypeCong.MALADIE
                ),

                congesRepository.countByType(
                        Conges.TypeCong.SANS_SOLDE
                ),

                // rôles absents
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

    public ArretDashboardDTO getArretStats() {

        LocalDateTime now = LocalDateTime.now();

        LocalDateTime startDay = now.minusDays(1);
        LocalDateTime startWeek = now.minusDays(7);

        return new ArretDashboardDTO(

                // Total
                arretRepository.count(),

                // Today
                arretRepository.countByDateDebutBetween(startDay, now),

                // Week
                arretRepository.countByDateDebutBetween(startWeek, now),

                // Temps perdu
                arretRepository.tempsPerduTotal(),

                // Moyenne durée
                arretRepository.avgArretDuration(),

                // taux blocage
                arretRepository.tauxBlocageOperations(),

                // top causes
                arretRepository.topCausesArret()
                        .stream()
                        .map(obj -> new ArretStatsDTO(
                                (String) obj[0],
                                (Long) obj[1]
                        ))
                        .toList()
        );
    }

    public List<EnginKPIDTO> getTopEngins() {

        return operationEnginRepository
                .getMostUsedEngins()
                .stream()
                .map(obj -> new EnginKPIDTO(

                        (Long) obj[0],
                        (String) obj[1],
                        (Long) obj[2]

                ))
                .toList();
    }


    public List<EnginUsageRateDTO> getEnginUsageRates() {

        return operationEnginRepository
                .getUsageRateByEngin()
                .stream()
                .map(obj -> new EnginUsageRateDTO(

                        (Long) obj[0],
                        (String) obj[1],
                        (Double) obj[2]

                ))
                .toList();
    }

    public List<EscaleKPIDTO> getEscalesStats() {

        return operationRepository
                .getEscalesStats()
                .stream()
                .map(obj -> new EscaleKPIDTO(

                        (String) obj[0],
                        (String) obj[1],
                        (Long) obj[2]

                ))
                .toList();
    }


    public List<EquipeKPIDTO> getBestTeams() {

        return operationRepository
                .getBestTeams()
                .stream()
                .map(obj -> new EquipeKPIDTO(

                        (Long) obj[0],
                        (String) obj[1],
                        (Long) obj[2],
                        (Long) obj[3]

                ))
                .toList();
    }

}