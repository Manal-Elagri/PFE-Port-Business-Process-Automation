package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.dto.ChefEscaleDashboardStats;
import Projet_Stage.PFE.dto.ProfileDTO;
import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.enums.RolePersonnel;
import Projet_Stage.PFE.repository.ShiftRepository;
import Projet_Stage.PFE.service.ChefDEscaleService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/chef-escale")
@RequiredArgsConstructor
public class ChefDEscaleController {

    private final ChefDEscaleService chefDEscaleService;
    private final ShiftRepository shiftRepository;


    @GetMapping("/profile")
    public ResponseEntity<ProfileDTO> dashboard() {

        User user = chefDEscaleService.getCurrentUser();

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
    // 1. EQUIPE
    // =====================================================

    @PostMapping("/equipes")
    public Equipe createEquipe(
            @RequestParam Long shiftId,
            @RequestParam String matriculeEquipe
    ) {
        return chefDEscaleService.createEquipe(shiftId, matriculeEquipe);
    }

    @PutMapping("/equipes/{id}")
    public Equipe updateEquipe(
            @PathVariable Long id,
            @RequestParam String matricule
    ) {
        return chefDEscaleService.updateEquipe(id, matricule);
    }

    @DeleteMapping("/equipes/{id}")
    public void deleteEquipe(@PathVariable Long id) {
        chefDEscaleService.deleteEquipe(id);
    }


    @GetMapping("/equipes/{id}")
    public Equipe getEquipeById(
            @PathVariable Long id
    ) {
        return chefDEscaleService.getEquipeById(id);
    }

    @GetMapping("/equipes/chef")
    public List<Equipe> getMyEquipes() {
        return chefDEscaleService.getMyEquipes();
    }
    // =====================================================
    // 2. AFFECTATION PERSONNEL
    // =====================================================


    @PostMapping("/equipes/{id}/assign-personnel")
    public void assignPersonnel(
            @PathVariable Long id,
            @RequestParam Long personnelId,
            @RequestParam RolePersonnel roleMetier
    ) {
        chefDEscaleService.assignPersonnelToEquipeWithRole(id, personnelId, roleMetier);
    }

    @PostMapping("/equipes/{id}/assign-chef-equipe")
    public void assignChefEquipe(
            @PathVariable Long id,
            @RequestParam Long chefEquipeId
    ) {
        chefDEscaleService.assignChefEquipe(id, chefEquipeId);
    }


    @GetMapping("/personnel/chefs-equipes")
    public List<Personnel> chefsEquipes() {
        return chefDEscaleService.getChefsEquipes();
    }

    @GetMapping("/personnel/employes")
    public List<Personnel> employes() {
        return chefDEscaleService.getEmployes();
    }

    // =====================================================
    // 3. SHIFT MANAGEMENT
    // =====================================================

    @GetMapping("/shift/active")
    public List<Shift> getActiveShifts() {

        LocalDate today = LocalDate.now();

        return shiftRepository.findAll()
                .stream()
                .filter(s -> s.getPlanningJour() != null
                        && !s.getPlanningJour().getDate().isBefore(today))
                .toList();
    }


    @PostMapping("/equipes/{id}/assign-equipe-shift")
    public void assignEquipeToShift(
            @PathVariable Long id,
            @RequestParam Long shiftId
    ) {
        chefDEscaleService.assignEquipeToShift(id, shiftId);
    }

    @DeleteMapping("/equipes/{id}/remove-equipe-shift")
    public void removeEquipeFromShift(@PathVariable Long id) {
        chefDEscaleService.removeEquipeFromShift(id);
    }

    // =====================================================
    // 4. SHIFT HISTORY
    // =====================================================

    @GetMapping("/shifts/history")
    public List<HistoriqueShift> getMyShiftHistory() {
        return chefDEscaleService.getMyShiftHistory();
    }

    // =====================================================
    // 5. DASHBOARD
    // =====================================================

    @GetMapping("/dashboard")
    public ChefEscaleDashboardStats getDashboard() {
        return chefDEscaleService.getDashboardStats();
    }

    // =====================================================
    // 6. CALENDAR
    // =====================================================

    @GetMapping("/calendar")
    public List<Equipe> getCalendar() {
        return chefDEscaleService.getMyShiftCalendar();
    }
}