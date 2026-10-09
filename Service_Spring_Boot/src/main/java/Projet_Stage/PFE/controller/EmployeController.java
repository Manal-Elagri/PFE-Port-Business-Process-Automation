package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.dto.ProfileDTO;
import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.enums.EtatEngin;
import Projet_Stage.PFE.repository.EnginRepository;
import Projet_Stage.PFE.repository.EscaleRepository;
import Projet_Stage.PFE.repository.PortierRepository;
import Projet_Stage.PFE.repository.PosteRepository;
import Projet_Stage.PFE.service.EmployeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/employe")
@RequiredArgsConstructor
public class EmployeController {

    private final EmployeService employeService;
    private final EscaleRepository escaleRepository;
    private final PosteRepository posteRepository;
    private final PortierRepository portierRepository;
    private final EnginRepository enginRepository;

    // =====================================================
    // PROFILE (dashboard sécurisé)
    // =====================================================

    @GetMapping("/me")
    public ResponseEntity<ProfileDTO> getMyProfile() {

        User user = employeService.getCurrentUser();
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
    // CONGÉS
    // =====================================================

    @PostMapping("/conges")
    public ResponseEntity<Conges> demanderConge(
            @RequestParam LocalDate dateDebut,
            @RequestParam LocalDate dateFin,
            @RequestParam Conges.TypeCong type
    ) {
        return ResponseEntity.ok(
                employeService.demanderConge(dateDebut, dateFin, type)
        );
    }

    @PutMapping("/conges/{id}")
    public ResponseEntity<Conges> modifierConge(
            @PathVariable Long id,
            @RequestParam LocalDate dateDebut,
            @RequestParam LocalDate dateFin,
            @RequestParam Conges.TypeCong type
    ) {
        return ResponseEntity.ok(
                employeService.modifierDemandeConge(id, dateDebut, dateFin, type)
        );
    }

    @DeleteMapping("/conges/{id}")
    public ResponseEntity<String> supprimerConge(@PathVariable Long id) {
        employeService.supprimerDemandeConge(id);
        return ResponseEntity.ok("Demande de congé supprimée");
    }

    @GetMapping("/conges")
    public ResponseEntity<List<Conges>> getMyConges() {
        return ResponseEntity.ok(
                employeService.getCongesByEmploye()
        );
    }

    // =====================================================
    // AFFECTATIONS / EQUIPES
    // =====================================================

    @GetMapping("/assignments")
    public ResponseEntity<List<EquipePersonnel>> getMyAssignments() {
        return ResponseEntity.ok(employeService.getMyAssignments());
    }

    @GetMapping("/assignments/shift/{shiftId}")
    public ResponseEntity<List<EquipePersonnel>> getByShift(@PathVariable Long shiftId) {
        return ResponseEntity.ok(employeService.getMyAssignmentsByShift(shiftId));
    }

    @GetMapping("/assignments/equipe/{equipeId}")
    public ResponseEntity<List<EquipePersonnel>> getByEquipe(@PathVariable Long equipeId) {
        return ResponseEntity.ok(employeService.getMyAssignmentsByEquipe(equipeId));
    }

    @GetMapping("/calendar")
    public ResponseEntity<List<EquipePersonnel>> getMyCalendar() {
        return ResponseEntity.ok(employeService.getMyShiftCalendar());
    }

    // =====================================================
    // HISTORIQUE
    // =====================================================

    @GetMapping("/history")
    public ResponseEntity<List<HistoriqueShift>> getMyHistory() {
        return ResponseEntity.ok(employeService.getMyHistory());
    }

    // =====================================================
    // OPERATION (POINTEUR)
    // =====================================================

    @GetMapping("/can-start-operation")
    public ResponseEntity<Boolean> canStartOperation() {
        return ResponseEntity.ok(employeService.canStartOperation());
    }

    @GetMapping("/operation-context")
    public ResponseEntity<Equipe> getOperationContext() {
        return ResponseEntity.ok(employeService.getMyCurrentOperationContext());
    }



    @GetMapping("/escales")
    public List<Map<String, Object>> getEscales() {
        return escaleRepository.findAll().stream().map(e -> {
            Map<String, Object> m = new HashMap<>();
            m.put("id", e.getId());
            m.put("numeroEscale", e.getNumeroEscale());
            m.put("dateArrivee", e.getDateArrivee());
            m.put("dateDepart", e.getDateDepart());

            if (e.getNavire() != null) {
                Map<String, Object> navire = new HashMap<>();
                navire.put("id", e.getNavire().getId());
                navire.put("nom", e.getNavire().getNom());
                navire.put("numeroIMO", e.getNavire().getNumeroIMO());
                m.put("navire", navire);
            } else {
                m.put("navire", null);
            }

            return m;
        }).toList();
    }

    @GetMapping("/postes")
    public List<Map<String, Object>> getPostes() {
        return posteRepository.findAll().stream().map(p -> {
            Map<String, Object> m = new HashMap<>();
            m.put("id", p.getId());
            m.put("numeroPoste", p.getNumeroPoste());
            m.put("localisation", p.getLocalisation());
            m.put("latitude", p.getLatitude());
            m.put("longitude", p.getLongitude());
            return m;
        }).toList();
    }

    @GetMapping("/portiers")
    public List<Map<String, Object>> getPortiers() {
        return portierRepository.findAll().stream().map(p -> {
            Map<String, Object> m = new HashMap<>();
            m.put("id", p.getId());
            m.put("code", p.getCode());
            m.put("nombreCameras", p.getNombreCameras());
            return m;
        }).toList();
    }

    @GetMapping("/engins/actifs")
    public List<Map<String, Object>> getEnginsActifs() {
        List<Engin> engins = enginRepository.findByEtat(EtatEngin.ACTIF);

        System.out.println("ENGINS ACTIFS COUNT = " + engins.size());

        return engins.stream().map(e -> {
            Map<String, Object> m = new HashMap<>();
            m.put("id", e.getId());
            m.put("type", e.getType());
            m.put("etat", e.getEtat().name());
            m.put("capacite", e.getCapacite());
            return m;
        }).toList();
    }


}