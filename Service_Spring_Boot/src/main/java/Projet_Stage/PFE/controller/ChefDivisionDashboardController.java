package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.dto.*;
import Projet_Stage.PFE.entities.Personnel;
import Projet_Stage.PFE.entities.Signature;
import Projet_Stage.PFE.entities.User;
import Projet_Stage.PFE.service.ChefDivisionDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chef-division")
@RequiredArgsConstructor
public class ChefDivisionDashboardController {

    private final ChefDivisionDashboardService service;


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
    // DASHBOARD GLOBAL
    // =====================================================

    @GetMapping("/dashboard")
    public ChefDivisionDashboardDTO getStats() {
        return service.getStats();
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
    // ARRÊTS DASHBOARD
    // =====================================================

    @GetMapping("/arrets/dashboard")
    public ArretDashboardDTO getArretStats() {
        return service.getArretStats();
    }

    // =====================================================
    // ENGINS KPI
    // =====================================================

    @GetMapping("/stats/engins/top")
    public List<EnginKPIDTO> getTopEngins() {
        return service.getTopEngins();
    }

    @GetMapping("/stats/engins/usage-rate")
    public List<EnginUsageRateDTO> getEnginUsageRates() {
        return service.getEnginUsageRates();
    }

    // =====================================================
    // ESCALES KPI
    // =====================================================

    @GetMapping("/stats/escales")
    public List<EscaleKPIDTO> getEscalesStats() {
        return service.getEscalesStats();
    }

    // =====================================================
    // ÉQUIPES KPI
    // =====================================================

    @GetMapping("/stats/equipes/best")
    public List<EquipeKPIDTO> getBestTeams() {
        return service.getBestTeams();
    }
}