package Projet_Stage.PFE.service;

import Projet_Stage.PFE.dto.ChefEscaleDashboardStats;
import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.enums.RolePersonnel;
import Projet_Stage.PFE.enums.RoleUser;
import Projet_Stage.PFE.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ChefDEscaleService {

    private final ShiftRepository shiftRepository;
    private final EquipeRepository equipeRepository;
    private final PersonnelRepository personnelRepository;
    private final EquipePersonnelRepository equipePersonnelRepository;
    private final HistoriqueShiftRepository historiqueShiftRepository;

    // =====================================================
    // CHEF ESCALE CONNECTÉ
    // =====================================================

    private Personnel  getChefEscaleConnecte() {

        User user = getCurrentUser();

        if (!RoleUser.CHEF_ESCALE.equals(user.getRole())) {
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

    // =====================================================
    // CHECK OWNERSHIP EQUIPE
    // =====================================================
    private Equipe getMyEquipe(Long equipeId) {

        Personnel chef = getChefEscaleConnecte();

        Equipe equipe = equipeRepository.findById(equipeId)
                .orElseThrow(() ->
                        new RuntimeException("Equipe introuvable"));

        if (!equipe.getChefEscale().getId().equals(chef.getId())) {
            throw new RuntimeException(
                    "Vous ne pouvez pas modifier cette équipe"
            );
        }

        return equipe;
    }


    public List<Equipe> getMyEquipes() {

        Personnel chef = getChefEscaleConnecte();

        return equipeRepository.findByChefEscaleId(chef.getId());
    }

    // =====================================================
    // 1. CREATE EQUIPE
    // =====================================================
    public Equipe createEquipe(
            Long shiftId,
            String matriculeEquipe
    ) {

        Personnel chef = getChefEscaleConnecte();

        Shift shift = shiftRepository.findById(shiftId)
                .orElseThrow(() ->
                        new RuntimeException("Shift introuvable"));

        Equipe equipe = new Equipe();

        equipe.setMatriculeEquipe(matriculeEquipe);
        equipe.setShift(shift);
        equipe.setChefEscale(chef);
        equipe.setPlanningJour(shift.getPlanningJour());

        return equipeRepository.save(equipe);
    }


    // =====================================================
    // 2. UPDATE EQUIPE
    // =====================================================
    public Equipe updateEquipe(
            Long equipeId,
            String newMatricule
    ) {

        Equipe equipe = getMyEquipe(equipeId);

        equipe.setMatriculeEquipe(newMatricule);

        return equipeRepository.save(equipe);
    }


    // =====================================================
    // 3. DELETE EQUIPE
    // =====================================================
    public void deleteEquipe(Long equipeId) {

        Equipe equipe = getMyEquipe(equipeId);

        equipeRepository.delete(equipe);
    }


    public Equipe getEquipeById(Long id) {

        Personnel chef = getChefEscaleConnecte();

        Equipe equipe = equipeRepository.findById(id)
                .orElseThrow(() ->
                        new RuntimeException("Equipe introuvable avec l'id : " + id));

        if (equipe.getChefEscale() == null ||
                !equipe.getChefEscale().getId().equals(chef.getId())) {

            throw new RuntimeException(
                    "Vous n'êtes pas autorisé à consulter cette équipe");
        }

        return equipe;
    }


    public List<Personnel> getChefsEquipes() {
        getChefEscaleConnecte();
        return personnelRepository.findByRole(RolePersonnel.CHEF_EQUIPE);
    }

    public List<Personnel> getEmployes() {

        getChefEscaleConnecte();

        return personnelRepository.findAll()
                .stream()
                .filter(p -> p.getRole().isEmploye())
                .toList();
    }
    // =====================================================
    // 4. ASSIGN PERSONNEL
    // =====================================================
    public void assignPersonnelToEquipeWithRole(
            Long equipeId,
            Long personnelId,
            RolePersonnel roleMetier
    ) {

        Equipe equipe = getMyEquipe(equipeId);

        boolean dejaDansShift =
                equipePersonnelRepository
                        .existsByPersonnelIdAndEquipe_Shift_Id(
                                personnelId,
                                equipe.getShift().getId()
                        );

        if (dejaDansShift) {
            throw new RuntimeException(
                    "Ce personnel est déjà affecté dans une autre équipe de cette shift"
            );
        }

        if (equipePersonnelRepository
                .existsByEquipeIdAndPersonnelId(
                        equipeId,
                        personnelId
                )) {

            throw new RuntimeException("Déjà assigné");
        }

        Personnel personnel = personnelRepository.findById(personnelId)
                .orElseThrow(() ->
                        new RuntimeException("Personnel introuvable"));

        if (
                personnel.getRole() == RolePersonnel.CHEF_ESCALE ||
                        personnel.getRole() == RolePersonnel.CHEF_SERVICE ||
                        personnel.getRole() == RolePersonnel.CHEF_DIVISION ||
                        personnel.getRole() == RolePersonnel.CHEF_EQUIPE
        ) {
            throw new RuntimeException(
                    "Ce personnel n'est pas autorisé ici"
            );
        }

        EquipePersonnel relation = new EquipePersonnel();

        relation.setEquipe(equipe);
        relation.setPersonnel(personnel);
        relation.setRoleMetier(roleMetier);

        equipePersonnelRepository.save(relation);
    }


    // =====================================================
    // 5. ASSIGN CHEF EQUIPE
    // =====================================================
    public void assignChefEquipe(
            Long equipeId,
            Long chefEquipeId
    ) {

        Equipe equipe = getMyEquipe(equipeId);

        Personnel chefEquipe =
                personnelRepository.findById(chefEquipeId)
                        .orElseThrow(() ->
                                new RuntimeException("Chef introuvable"));

        if (chefEquipe.getRole() != RolePersonnel.CHEF_EQUIPE) {
            throw new RuntimeException(
                    "Ce personnel n'est pas chef d'équipe"
            );
        }

        equipe.setChefEquipe(chefEquipe);

        equipeRepository.save(equipe);
    }


    // =====================================================
    // 6. CHANGER SHIFT
    // =====================================================
    public void assignEquipeToShift(
            Long equipeId,
            Long shiftId
    ) {

        Personnel chef = getChefEscaleConnecte();

        Equipe equipe = getMyEquipe(equipeId);

        Shift shift = shiftRepository.findById(shiftId)
                .orElseThrow(() ->
                        new RuntimeException("Shift introuvable"));

        equipe.setShift(shift);

        equipeRepository.save(equipe);


        HistoriqueShift historique =
                new HistoriqueShift();

        historique.setChefEscale(chef);
        historique.setEquipe(equipe);
        historique.setShift(shift);
        historique.setDateDebut(LocalDateTime.now());
        historique.setActive(true);

        historiqueShiftRepository.save(historique);
    }


    // =====================================================
    // 7. REMOVE SHIFT
    // =====================================================
    public void removeEquipeFromShift(
            Long equipeId
    ) {

        Equipe equipe = getMyEquipe(equipeId);

        Optional<HistoriqueShift> historiqueOpt =
                historiqueShiftRepository
                        .findByEquipeIdAndActiveTrue(
                                equipeId
                        );

        if (historiqueOpt.isPresent()) {

            HistoriqueShift historique =
                    historiqueOpt.get();

            historique.setDateFin(
                    LocalDateTime.now()
            );

            historique.setActive(false);

            historiqueShiftRepository.save(
                    historique
            );
        }

        equipe.setShift(null);

        equipeRepository.save(equipe);
    }


    // =====================================================
    // 8. DASHBOARD
    // =====================================================
    public List<HistoriqueShift> getMyShiftHistory() {

        Personnel chef = getChefEscaleConnecte();

        return historiqueShiftRepository
                .findByChefEscaleIdOrderByDateDebutDesc(chef.getId());
    }

    public ChefEscaleDashboardStats getDashboardStats() {

        Personnel chef =
                getChefEscaleConnecte();

        long totalEquipes =
                equipeRepository
                        .countByChefEscaleId(
                                chef.getId()
                        );

        long totalPersonnels =
                equipePersonnelRepository
                        .countByEquipe_ChefEscale_Id(
                                chef.getId()
                        );

        long totalShifts =
                historiqueShiftRepository
                        .countDistinctShiftsByChefEscale(
                                chef.getId()
                        );

        long totalMouvements =
                historiqueShiftRepository
                        .countByChefEscaleId(
                                chef.getId()
                        );

        return new ChefEscaleDashboardStats(
                totalEquipes,
                totalPersonnels,
                totalShifts,
                totalMouvements
        );
    }

    // =====================================================
    // 9. Calendrier des shifts (planning du jour/semaine)
    // =====================================================
    public List<Equipe> getMyShiftCalendar() {

        Personnel chef = getChefEscaleConnecte();

        return equipeRepository
                .findByChefEscaleId(chef.getId());
    }

}