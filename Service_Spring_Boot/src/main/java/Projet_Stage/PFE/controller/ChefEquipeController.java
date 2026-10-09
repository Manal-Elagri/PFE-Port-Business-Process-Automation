package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.dto.ChefEquipeDashboardDTO;
import Projet_Stage.PFE.dto.ProfileDTO;
import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.service.ChefDEquipeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/chef-equipe")
@RequiredArgsConstructor
public class ChefEquipeController {

    private final ChefDEquipeService chefService;


    @GetMapping("/profile")
    public ResponseEntity<ProfileDTO> dashboard() {

        User user = chefService.getCurrentUser();

        Personnel p = user.getPersonnel();

        return ResponseEntity.ok(new ProfileDTO(
                p.getId(),
                p.getNom(),
                p.getPrenom(),
                p.getEmail(),
                p.getRole(),
                p.getImageURL()
        ));
    }
    // =====================================================
    // DASHBOARD
    // =====================================================

    @GetMapping("/dashboard")
    public ChefEquipeDashboardDTO getDashboard() {
        return chefService.getDashboardStats();
    }

    // =====================================================
    // ÉQUIPE / AFFECTATIONS
    // =====================================================

    @GetMapping("/equipe")
    public Equipe getMyTeam() {
        return chefService.getMyManagedTeam();
    }

    @GetMapping("/assignments")
    public List<EquipePersonnel> getMyAssignments() {
        return chefService.getMyAssignments();
    }

    @GetMapping("/assignments/shift/{shiftId}")
    public List<EquipePersonnel> getByShift(@PathVariable Long shiftId) {
        return chefService.getMyAssignmentsByShift(shiftId);
    }

    @GetMapping("/assignments/equipe/{equipeId}")
    public List<EquipePersonnel> getByEquipe(@PathVariable Long equipeId) {
        return chefService.getMyAssignmentsByEquipe(equipeId);
    }

    @GetMapping("/calendar")
    public List<EquipePersonnel> getCalendar() {
        return chefService.getMyShiftCalendar();
    }

    @GetMapping("/history")
    public List<HistoriqueShift> getHistory() {
        return chefService.getMyHistory();
    }

    // =====================================================
    // CONGÉS
    // =====================================================

    @GetMapping("/conges")
    public List<Conges> getMyConges() {
        return chefService.getMyConges();
    }

    @GetMapping("/conges/history")
    public List<Conges> getMyCongeHistory() {
        return chefService.getMyCongeHistory();
    }

    @PostMapping("/conges")
    public Conges demanderConge(
            @RequestParam LocalDate dateDebut,
            @RequestParam LocalDate dateFin,
            @RequestParam Conges.TypeCong type
    ) {
        return chefService.demanderConge(dateDebut, dateFin, type);
    }

    @PutMapping("/conges/{id}")
    public Conges modifierConge(
            @PathVariable Long id,
            @RequestParam LocalDate dateDebut,
            @RequestParam LocalDate dateFin,
            @RequestParam Conges.TypeCong type
    ) {
        return chefService.modifierDemandeConge(id, dateDebut, dateFin, type);
    }

    @DeleteMapping("/conges/{id}")
    public boolean supprimerConge(@PathVariable Long id) {
        return chefService.supprimerDemandeConge(id);
    }

    @GetMapping("/conges/absents")
    public List<Conges> getAbsentMembersDetails() {
        return chefService.getAbsentMembersTodayDetails();
    }

    @GetMapping("/conges/absents/count")
    public long getAbsentCount() {
        return chefService.getAbsentMembersToday();
    }

    // =====================================================
    // ÉQUIPE (INFO SIMPLE)
    // =====================================================

    @GetMapping("/team")
    public Equipe getTeamInfo() {
        return chefService.getMyManagedTeam();
    }
}