package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.dto.*;
import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.enums.*;
import Projet_Stage.PFE.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;


    @GetMapping("/profile")
    public ResponseEntity<ProfileDTO> dashboard() {

        User user = adminService.getCurrentUser();

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
    // =========================
    // PLANNING
    // =========================

    @PostMapping("/planning")
    public PlanningJour createPlanning(@RequestParam LocalDate date) {
        return adminService.createPlanning(date);
    }

    @PutMapping("/planning/{id}")
    public PlanningJour updatePlanning(
            @PathVariable Long id,
            @RequestParam LocalDate date
    ) {
        return adminService.updatePlanning(id, date);
    }

    @DeleteMapping("/planning/{id}")
    public void deletePlanning(@PathVariable Long id) {
        adminService.deletePlanning(id);
    }

    @GetMapping("/planning")
    public List<PlanningJour> getAllPlannings() {
        return adminService.getAllPlannings();
    }

    @GetMapping("/planning/{id}/shifts")
    public List<Shift> getShiftsByPlanning(@PathVariable Long id) {
        return adminService.getShiftsByPlanning(id);
    }

    // =========================
    // SHIFTS
    // =========================

    @PostMapping("/shift")
    public Shift createShift(
            @RequestParam Long planningId,
            @RequestParam TypeShift typeShift,
            @RequestParam LocalTime heureDebut,
            @RequestParam LocalTime heureFin
    ) {
        return adminService.createShift(planningId, typeShift, heureDebut, heureFin);
    }

    @PutMapping("/shift/{id}")
    public Shift updateShift(
            @PathVariable Long id,
            @RequestParam LocalTime heureDebut,
            @RequestParam LocalTime heureFin
    ) {
        return adminService.updateShift(id, heureDebut, heureFin);
    }

    @PutMapping("/shift/assign")
    public Shift assignManagers(
            @RequestParam Long shiftId,
            @RequestParam Long chefServiceId,
            @RequestParam Long chefDivisionId
    ) {
        return adminService.assignManagersToShift(shiftId, chefServiceId, chefDivisionId);
    }

    @DeleteMapping("/shift/{id}")
    public void deleteShift(@PathVariable Long id) {
        adminService.deleteShift(id);
    }

    // AdminController.java
    // Dans AdminController.java
    @GetMapping("/shift/{id}")
    public Map<String, Object> getShift(@PathVariable Long id) {
        Shift shift = adminService.getShiftById(id);
        Map<String, Object> result = new HashMap<>();
        result.put("id", shift.getId());
        result.put("type", shift.getType());
        result.put("heureDebut", shift.getHeureDebut());
        result.put("heureFin", shift.getHeureFin());
        result.put("chefService", shift.getChefService());
        result.put("chefDivision", shift.getChefDivision());
        // ← date du planning incluse
        result.put("planningDate", shift.getPlanningJour().getDate().toString());
        return result;
    }
    // =========================
    // HISTORIQUE SHIFTS
    // =========================

    @GetMapping("/history/equipe/{id}")
    public List<HistoriqueShift> getEquipeHistory(@PathVariable Long id) {
        return adminService.getEquipeHistory(id);
    }

    @GetMapping("/history/shift/{id}")
    public List<HistoriqueShift> getShiftHistory(@PathVariable Long id) {
        return adminService.getShiftHistory(id);
    }

    @GetMapping("/history/all")
    public List<HistoriqueShift> getAllHistory() {
        return adminService.getAllShiftHistory();
    }

    // =========================
    // DEMANDES D'INSCRIPTION
    // =========================

    @GetMapping("/demandes")
    public List<DemandeInscription> getAllRequests() {
        return adminService.getAllRequests();
    }

    @GetMapping("/demandes/pending")
    public List<DemandeInscription> getPendingRequests() {
        return adminService.getPendingRequests();
    }

    @PutMapping("/demandes/approve/{id}")
    public void approve(@PathVariable Long id) {
        adminService.approveRequest(id);
    }

    @PutMapping("/demandes/reject/{id}")
    public void reject(@PathVariable Long id) {
        adminService.rejectRequest(id);
    }

    // =========================
    // PERSONNEL
    // =========================

    /// ===================== UPDATE PERSONNEL =====================
    @PutMapping("/{personnelId}")
    public ResponseEntity<Personnel> updatePersonnel(
            @PathVariable Long personnelId,
            @RequestBody UpdatePersonnelRequest request
    ) {

        Personnel updated = adminService.updatePersonnel(
                personnelId,
                request.getNom(),
                request.getPrenom(),
                request.getTelephone(),
                request.getEmail(),
                request.getImageURL(),
                request.getCin(),
                request.getPassword(),
                request.getRolePersonnel()
        );

        return ResponseEntity.ok(updated);
    }


    /// ===================== DELETE PERSONNEL =====================
    @DeleteMapping("/{personnelId}")
    public ResponseEntity<String> deletePersonnel(
            @PathVariable Long personnelId
    ) {

        adminService.deletePersonnel(personnelId);

        return ResponseEntity.ok(
                "Personnel supprimé avec succès"
        );
    }
    @GetMapping("/personnel/chefs-escales")
    public List<Personnel> chefsEscales() {
        return adminService.getChefsEscales();
    }

    @GetMapping("/personnel/chefs-services")
    public List<Personnel> chefsServices() {
        return adminService.getChefsServices();
    }

    @GetMapping("/personnel/chefs-divisions")
    public List<Personnel> chefsDivisions() {
        return adminService.getChefsDivisions();
    }

    @GetMapping("/personnel/chefs-equipes")
    public List<Personnel> chefsEquipes() {
        return adminService.getChefsEquipes();
    }

    @GetMapping("/personnel/employes")
    public List<Personnel> employes() {
        return adminService.getEmployes();
    }

    // =========================
    // CONGÉS
    // =========================

    @GetMapping("/conges")
    public List<Conges> getAllConges() {
        return adminService.getAllConges();
    }

    @GetMapping("/conges/jour")
    public List<Conges> getCongesParJour(@RequestParam LocalDate date) {
        return adminService.getCongesParJour(date);
    }

    @GetMapping("/conges/mois")
    public List<Conges> getCongesParMois(
            @RequestParam int annee,
            @RequestParam int mois
    ) {
        return adminService.getCongesParMois(annee, mois);
    }

    @PutMapping("/conges/{id}")
    public Conges updateConge(
            @PathVariable Long id,
            @RequestParam Conges.StatutConge status
    ) {
        return adminService.changerStatutDemandeConge(id, status);
    }

    // =========================
    // ENGINS
    // =========================

    @PostMapping("/engins")
    public Engin createEngin(
            @RequestParam String type,
            @RequestParam EtatEngin etat,
            @RequestParam Double capacite
    ) {
        return adminService.createEngin(type, etat, capacite);
    }

    @PutMapping("/engins/{id}")
    public Engin updateEngin(
            @PathVariable Long id,
            @RequestParam EtatEngin etat
    ) {
        return adminService.updateEngin(id, etat);
    }

    @DeleteMapping("/engins/{id}")
    public void deleteEngin(@PathVariable Long id) {
        adminService.deleteEngin(id);
    }

    @GetMapping("/engins")
    public List<Engin> getEngins() {
        return adminService.getAllEngins();
    }

    // =========================
    // POSTES
    // =========================

    @PostMapping("/postes")
    public Poste createPoste(
            @RequestParam Integer numero,
            @RequestParam String localisation,
            @RequestParam Double latitude,
            @RequestParam Double longitude
    ) {
        return adminService.createPoste(numero, localisation, latitude, longitude);
    }

    @PutMapping("/postes/{id}")
    public Poste updatePoste(
            @PathVariable Long id,
            @RequestParam Integer numero,
            @RequestParam String localisation,
            @RequestParam Double latitude,
            @RequestParam Double longitude
    ) {
        return adminService.updatePoste(id, numero, localisation, latitude, longitude);
    }

    @DeleteMapping("/postes/{id}")
    public void deletePoste(@PathVariable Long id) {
        adminService.deletePoste(id);
    }

    @GetMapping("/postes")
    public List<Poste> getPostes() {
        return adminService.getAllPostes();
    }

    // =========================
    // PORTIERS
    // =========================

    @PostMapping("/portiers")
    public Portier createPortier(
            @RequestParam String code,
            @RequestParam Integer nombreCameras
    ) {
        return adminService.createPortier(code, nombreCameras);
    }

    @PutMapping("/portiers/{id}")
    public Portier updatePortier(
            @PathVariable Long id,
            @RequestParam Integer nombreCameras
    ) {
        return adminService.updatePortier(id, nombreCameras);
    }

    @DeleteMapping("/portiers/{id}")
    public void deletePortier(@PathVariable Long id) {
        adminService.deletePortier(id);
    }

    @GetMapping("/portiers")
    public List<Portier> getPortiers() {
        return adminService.getAllPortiers();
    }

    // =========================
    // NAVIRES
    // =========================

    @PostMapping("/navires")
    public Navire createNavire(
            @RequestParam String nom,
            @RequestParam String numeroIMO
    ) {
        return adminService.createNavire(nom, numeroIMO);
    }

    @PutMapping("/navires/{id}")
    public Navire updateNavire(
            @PathVariable Long id,
            @RequestParam String nom,
            @RequestParam String numeroIMO
    ) {
        return adminService.updateNavire(id, nom, numeroIMO);
    }

    @GetMapping("/navires")
    public List<Navire> getNavires() {
        return adminService.getAllNavires();
    }

    @GetMapping("/navires/{id}")
    public Navire getNavire(@PathVariable Long id) {
        return adminService.getNavireById(id);
    }

    @DeleteMapping("/navires/{id}")
    public void deleteNavire(@PathVariable Long id) {
        adminService.deleteNavire(id);
    }

    // =========================
    // ESCALES
    // =========================

    @PostMapping("/escales")
    public Escale createEscale(
            @RequestParam String numeroEscale,
            @RequestParam LocalDate dateArrivee,
            @RequestParam LocalDate dateDepart,
            @RequestParam Long navireId
    ) {
        return adminService.createEscale(
                numeroEscale,
                dateArrivee,
                dateDepart,
                navireId
        );
    }

    @PutMapping("/escales/{id}")
    public Escale updateEscale(
            @PathVariable Long id,
            @RequestParam String numeroEscale,
            @RequestParam LocalDate dateArrivee,
            @RequestParam LocalDate dateDepart,
            @RequestParam Long navireId
    ) {
        return adminService.updateEscale(
                id,
                numeroEscale,
                dateArrivee,
                dateDepart,
                navireId
        );
    }

    @GetMapping("/escales")
    public List<Escale> getEscales() {
        return adminService.getAllEscales();
    }

    @GetMapping("/escales/navire/{navireId}")
    public List<Escale> getByNavire(@PathVariable Long navireId) {
        return adminService.getEscalesByNavire(navireId);
    }

    @DeleteMapping("/escales/{id}")
    public void deleteEscale(@PathVariable Long id) {
        adminService.deleteEscale(id);
    }

    // =========================
    // STATISTIQUES
    // =========================

    @GetMapping("/stats/dashboard")
    public AdminDashboardStats profiledashboard() {
        return adminService.getDashboardStats();
    }

    @GetMapping("/stats/engins/most-used")
    public List<ResourceUsageDTO> mostUsedEngins() {
        return adminService.getMostUsedEngins();
    }

    @GetMapping("/stats/postes/most-used")
    public List<ResourceUsageDTO> mostUsedPostes() {
        return adminService.getMostUsedPostes();
    }

    @GetMapping("/stats/portiers/most-used")
    public List<ResourceUsageDTO> mostUsedPortiers() {
        return adminService.getMostUsedPortiers();
    }

    @GetMapping("/stats/engins/unused")
    public List<Engin> unusedEngins() {
        return adminService.getUnusedEnginsStats();
    }

    @GetMapping("/stats/engins/usage-rate")
    public List<StatsRateDTO> enginsUsageRate() {
        return adminService.getEnginsUsageRateStats();
    }

    @GetMapping("/stats/postes/unused")
    public List<Poste> unusedPostes() {
        return adminService.getUnusedPostesStats();
    }

    @GetMapping("/stats/portiers/containers")
    public List<StatsCountDTO> containersByPortier() {
        return adminService.getContainersByPortierStats();
    }

    @GetMapping("/stats/operation")
    public OperationStatsDTO operationStats() {
        return adminService.getOperationStats();
    }

    @GetMapping("/stats/escales/active")
    public long activeEscales() {
        return adminService.getActiveEscales();
    }

    @GetMapping("/stats/navires/active")
    public long activeNavires() {
        return adminService.getActiveNavires();
    }


}