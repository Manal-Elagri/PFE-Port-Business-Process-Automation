package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.dto.ChefServiceDashboardDTO;
import Projet_Stage.PFE.dto.CongeDashboardDTO;
import Projet_Stage.PFE.dto.EquipeDTO;
import Projet_Stage.PFE.dto.ProfileDTO;
import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.service.ChefServiceDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/chef-service")
@RequiredArgsConstructor
public class ChefServiceDashboardController {

    private final ChefServiceDashboardService service;


    @GetMapping("/profile")
    public ResponseEntity<ProfileDTO> dashboard() {

        User user = service.getCurrentUser();

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
    // DASHBOARD PRINCIPAL
    // =====================================================

    @GetMapping("/dashboard")
    public ChefServiceDashboardDTO getStats(
            @RequestParam Long shiftId
    ) {
        return service.getStats(shiftId);
    }

    // =====================================================
    // SIGNATURES
    // =====================================================

    @GetMapping("/signatures/history")
    public List<Signature> getMySignatureHistory() {
        return service.getMySignatureHistory();
    }

    // =====================================================
    // CONGÉS DASHBOARD
    // =====================================================

    @GetMapping("/conges/dashboard")
    public CongeDashboardDTO getCongeDashboard() {
        return service.getCongeDashboard();
    }

    // =====================================================
    // CALENDRIER DES SHIFTS
    // =====================================================

    @GetMapping("/shifts/calendar")
    public List<Shift> getShiftCalendar(
            @RequestParam LocalDate date
    ) {
        return service.getShiftCalendar(date);
    }

    // =====================================================
    // HISTORIQUE D'UN SHIFT
    // =====================================================

    @GetMapping("/shifts/{shiftId}/history")
    public List<HistoriqueShift> getShiftWorkHistory(
            @PathVariable Long shiftId
    ) {
        return service.getShiftWorkHistory(shiftId);
    }

    // =====================================================
    // ÉQUIPES D'UN SHIFT
    // =====================================================

    @GetMapping("/shifts/{shiftId}/equipes")
    public List<EquipeDTO> getEquipesByShift(
            @PathVariable Long shiftId
    ) {
        return service
                .getEquipesByShift(shiftId)
                .stream()
                .map(e ->
                        new EquipeDTO(
                                e.getId(),
                                e.getMatriculeEquipe()
                        )
                )
                .toList();
    }

    // =====================================================
    // ÉQUIPES ACTIVES AUJOURD'HUI
    // =====================================================

    @GetMapping("/equipes/active-today")
    public List<Equipe> getActiveTeamsToday() {
        return service.getActiveTeamsToday();
    }

}