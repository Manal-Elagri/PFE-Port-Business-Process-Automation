package Projet_Stage.PFE.service;

import Projet_Stage.PFE.dto.*;
import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.enums.*;
import Projet_Stage.PFE.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
@Service
@RequiredArgsConstructor
public class AdminService {

    private final EmailService emailService;
    private final CongesRepository congesRepository;
    private final PlanningJourRepository planningRepository;
    private final ShiftRepository shiftRepository;
    private final EquipeRepository equipeRepository;
    private final HistoriqueShiftRepository historiqueShiftRepository;
    private final DemandeInscriptionRepository demandeRepository;
    private final PersonnelRepository personnelRepository;
    private final UserRepository userRepository;
    private final EnginRepository enginRepository;
    private final PosteRepository posteRepository;
    private final PortierRepository portierRepository;
    private final OperationRepository operationRepository;
    private final NavireRepository navireRepository;
    private final EscaleRepository escaleRepository;
    private final PasswordEncoder passwordEncoder;

    private Personnel  getAdminConnecte() {

        User user = getCurrentUser();

        if (!RoleUser.ADMIN.equals(user.getRole())) {
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

    /// ============ Gestion Des Planning ==============

    public PlanningJour createPlanning(LocalDate date) {

        getAdminConnecte();

        if (planningRepository.existsByDate(date)) {
            throw new RuntimeException("Planning déjà existant");
        }

        PlanningJour planning = new PlanningJour();
        planning.setDate(date);

        return planningRepository.save(planning);
    }

    public PlanningJour updatePlanning(
            Long planningId,
            LocalDate newDate
    ){

        getAdminConnecte();

        PlanningJour planning =
                planningRepository.findById(planningId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Planning introuvable"
                                ));

        planning.setDate(newDate);

        return planningRepository.save(planning);
    }


    public void deletePlanning(
            Long planningId
    ){

        getAdminConnecte();

        PlanningJour planning =
                planningRepository.findById(planningId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Planning introuvable"
                                ));

        if(!planning.getShifts().isEmpty()){
            throw new RuntimeException(
                    "Impossible de supprimer : shifts existants"
            );
        }

        planningRepository.delete(planning);
    }

    public List<PlanningJour> getAllPlannings() {
        return planningRepository.findAll();
    }

    public List<Shift> getShiftsByPlanning(Long planningId) {
        return shiftRepository.findByPlanningJourId(planningId);
    }
    /// ============ Gestion Des Shifts ==============

    public Shift createShift(
            Long planningId,
            TypeShift typeShift,
            LocalTime heureDebut,
            LocalTime heureFin
    ) {

        getAdminConnecte();

        PlanningJour planning =
                planningRepository.findById(planningId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Planning introuvable"
                                ));

        if(
                shiftRepository.existsByPlanningJourIdAndType(
                        planningId,
                        typeShift
                )
        ){
            throw new RuntimeException(
                    "Shift déjà existant"
            );
        }

        Shift shift = new Shift();

        shift.setPlanningJour(planning);
        shift.setType(typeShift);
        shift.setHeureDebut(heureDebut);
        shift.setHeureFin(heureFin);

        return shiftRepository.save(shift);
    }


    public Shift updateShift(

            Long shiftId,
            LocalTime debut,
            LocalTime fin
    ){

        getAdminConnecte();

        Shift shift =
                shiftRepository.findById(shiftId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Shift introuvable"
                                ));

        shift.setHeureDebut(debut);
        shift.setHeureFin(fin);

        return shiftRepository.save(shift);
    }

    public Shift assignManagersToShift(
            Long shiftId,
            Long chefServiceId,
            Long chefDivisionId
    ) {

        getAdminConnecte();

        Shift shift = shiftRepository.findById(shiftId)
                .orElseThrow(() ->
                        new RuntimeException("Shift introuvable"));

        Personnel chefService = personnelRepository
                .findById(chefServiceId)
                .orElseThrow(() ->
                        new RuntimeException("Chef service introuvable"));

        Personnel chefDivision = personnelRepository
                .findById(chefDivisionId)
                .orElseThrow(() ->
                        new RuntimeException("Chef division introuvable"));

        // validation métier
        if (chefService.getRole() != RolePersonnel.CHEF_SERVICE) {
            throw new RuntimeException(
                    "Ce personnel n'est pas chef service"
            );
        }

        if (chefDivision.getRole() != RolePersonnel.CHEF_DIVISION) {
            throw new RuntimeException(
                    "Ce personnel n'est pas chef division"
            );
        }

        shift.setChefService(chefService);
        shift.setChefDivision(chefDivision);

        return shiftRepository.save(shift);
    }


    public void deleteShift(

            Long shiftId
    ){

        getAdminConnecte();

        Shift shift = shiftRepository.findById(shiftId)
                .orElseThrow(() -> new RuntimeException("Shift introuvable"));

        // detach équipes
        List<Equipe> equipes = equipeRepository.findByShiftId(shiftId);
        for (Equipe e : equipes) {
            e.setShift(null);
            equipeRepository.save(e);
        }

        shiftRepository.delete(shift);
    }

    // AdminService.java
    public Shift getShiftById(Long id) {
        return shiftRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shift introuvable"));
    }
    /// ====================== Historique Des Shifts =======================

    public List<HistoriqueShift> getEquipeHistory(
            Long equipeId
    ){
        return historiqueShiftRepository
                .findByEquipeIdOrderByDateDebutDesc(
                        equipeId
                );
    }


    public List<HistoriqueShift> getShiftHistory(
            Long shiftId
    ){
        return historiqueShiftRepository
                .findByShiftIdOrderByDateDebutDesc(
                        shiftId
                );
    }

    // Tous les historiques (global)
    public List<HistoriqueShift> getAllShiftHistory() {
        getAdminConnecte();
        return historiqueShiftRepository.findAllByOrderByDateDebutDesc();
    }

    /// =============== Gestion Des Demandes De Creation Des Comptes ================

    // 1. APPROUVER DEMANDE

    public void approveRequest(
            Long demandeId
    ) {

        DemandeInscription demande =
                demandeRepository.findById(demandeId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Demande introuvable"
                                ));

        if (demande.getStatut()
                != StatutDemande.EN_ATTENTE) {

            throw new RuntimeException(
                    "Demande déjà traitée"
            );
        }

        // créer personnel
        Personnel personnel =
                new Personnel();

        personnel.setNom(
                demande.getNom()
        );

        personnel.setPrenom(
                demande.getPrenom()
        );

        personnel.setImageURL(
                demande.getImageURL()
        );

        personnel.setTelephone(
                demande.getTelephone()
        );

        personnel.setEmail(
                demande.getEmail()
        );

        personnel.setRole(
                demande.getRoleDemande()
        );

        personnel =
                personnelRepository.save(personnel);


        // créer user
        User user =
                new User();

        user.setCin(
                demande.getCin()
        );

        user.setEmail(
                demande.getEmail()
        );

        user.setPassword(
                demande.getPassword()
        );

        user.setPersonnel(
                personnel

        );

        user.setRole(
                mapToUserRole(
                        demande.getRoleDemande()
                )
        );

        userRepository.save(user);


        // MAJ demande
        demande.setStatut(
                StatutDemande.ACCEPTEE
        );

        demandeRepository.save(demande);
    }



    // 2. REFUSER DEMANDE

    public void rejectRequest(
            Long demandeId
    ) {

        DemandeInscription demande =
                demandeRepository.findById(demandeId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Demande introuvable"
                                ));

        demande.setStatut(
                StatutDemande.REFUSEE
        );

        demandeRepository.save(demande);
    }


    // 3. MAPPING ROLE

    private RoleUser mapToUserRole(RolePersonnel role) {

        return switch (role) {
            case CHEF_ESCALE -> RoleUser.CHEF_ESCALE;
            case CHEF_SERVICE -> RoleUser.CHEF_SERVICE;
            case CHEF_DIVISION -> RoleUser.CHEF_DIVISION;
            case CHEF_EQUIPE -> RoleUser.CHEF_EQUIPE;
            default -> RoleUser.EMPLOYE;
        };
    }

    // 4. LISTE DES DEMANDES EN ATTENTE

    public List<DemandeInscription> getPendingRequests() {

        return demandeRepository.findByStatut(StatutDemande.EN_ATTENTE);
    }

    public List<DemandeInscription> getAllRequests() {
        getAdminConnecte();
        return demandeRepository.findAll();
    }

    /// =============== Gestion Des Comptes Des Personnes ================

    @Transactional
    public Personnel updatePersonnel(
            Long personnelId,
            String nom,
            String prenom,
            String telephone,
            String email,
            String imageURL,
            String cin,
            String password,
            RolePersonnel rolePersonnel
    ) {

        getAdminConnecte();

        Personnel personnel = personnelRepository.findById(personnelId)
                .orElseThrow(() -> new RuntimeException("Personnel introuvable"));

        // 🔹 update Personnel
        personnel.setNom(nom);
        personnel.setPrenom(prenom);
        personnel.setTelephone(telephone);
        personnel.setEmail(email);
        personnel.setImageURL(imageURL);
        personnel.setRole(rolePersonnel);

        // 🔹 update User lié
        User user = userRepository.findByPersonnelId(personnelId)
                .orElseThrow(() -> new RuntimeException("Compte user introuvable"));

        user.setEmail(email);
        user.setCin(cin);

        if (password != null && !password.isBlank()) {
            user.setPassword(password); // (idéalement encoder si Spring Security)
        }

        user.setRole(mapToUserRole(rolePersonnel));

        userRepository.save(user);

        return personnelRepository.save(personnel);
    }

    @Transactional
    public void deletePersonnel(
            Long personnelId
    ) {

        getAdminConnecte();

        Personnel personnel =
                personnelRepository.findById(personnelId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Personnel introuvable"
                                ));

        User user =
                userRepository
                        .findByPersonnelId(
                                personnelId
                        )
                        .orElse(null);

        if (user != null) {
            userRepository.delete(user);
        }

        personnelRepository.delete(
                personnel
        );
    }

    private void syncUser(Personnel p, User u, String cin, String email, RolePersonnel role) {
        u.setCin(cin);
        u.setEmail(email);
        u.setRole(mapToUserRole(role));
    }

    public List<Personnel> getChefsEscales() {
        getAdminConnecte();
        return personnelRepository.findByRole(RolePersonnel.CHEF_ESCALE);
    }

    public List<Personnel> getChefsServices() {
        getAdminConnecte();
        return personnelRepository.findByRole(RolePersonnel.CHEF_SERVICE);
    }

    public List<Personnel> getChefsEquipes() {
        getAdminConnecte();
        return personnelRepository.findByRole(RolePersonnel.CHEF_EQUIPE);
    }

    public List<Personnel> getEmployes() {

        getAdminConnecte();

        return personnelRepository.findAll()
                .stream()
                .filter(p -> p.getRole().isEmploye())
                .toList();
    }

    public List<Personnel> getChefsDivisions() {

        getAdminConnecte();

        return personnelRepository.findByRole(
                RolePersonnel.CHEF_DIVISION
        );
    }


    // ******************************************* Gestion des Congés **************************************** //


    // ✅ Approuver un congé
    // Méthode générique pour changer l'état d'un congé + notifier l'employé

    @Transactional
    public Conges changerStatutDemandeConge(Long congeId,
                                            Conges.StatutConge newStatus) {
        // 🔎 Récupération du congé
        Conges conges = congesRepository.findById(congeId)
                .orElseThrow(() -> new RuntimeException("Demande de congé introuvable avec ID : " + congeId));

        // Vérifier si la demande est encore en attente
        if (conges.getStatut() != Conges.StatutConge.EN_ATTENTE) {
            throw new RuntimeException("Cette demande de congé a déjà été traitée !");
        }

        // Mise à jour du statut
        conges.setStatut(newStatus);

        // Sauvegarde en base
        Conges congesMaj = congesRepository.save(conges);

        // 🔔 Envoi notification à l’employé
        String email = conges.getEmploye().getEmail(); // assure-toi que ton entité Employe a bien un champ email
        String employeNom = conges.getEmploye().getNom();
        LocalDate dateDebut= conges.getDateDebut();
        LocalDate dateFin= conges.getDateFin();
        emailService.sendCongeStatutNotification(email, employeNom, dateDebut, dateFin,newStatus);

        return congesMaj;
    }


    // ✅ Afficher toutes les demandes
    public List<Conges> getAllConges() {
        return congesRepository.findAll();
    }

    // ✅ Afficher les employés en congé à une date donnée (ex: 2025-08-17)
    public List<Conges> getCongesParJour(LocalDate date) {
        return congesRepository.findByDateDebutLessThanEqualAndDateFinGreaterThanEqual(date, date);
    }

    // ✅ Afficher les employés en congé dans un mois donné
    public List<Conges> getCongesParMois(int annee, int mois) {
        LocalDate debut = LocalDate.of(annee, mois, 1);
        LocalDate fin = debut.withDayOfMonth(debut.lengthOfMonth()); // dernier jour du mois
        return congesRepository.findByDateDebutBetween(debut, fin);
    }


    /// =====================================================
   /// GESTION DES ENGINS
  /// =====================================================

    public Engin createEngin(
            String type,
            EtatEngin etat,
            Double capacite
    ) {

        getAdminConnecte();

        Engin engin = new Engin();

        engin.setType(type);
        engin.setEtat(etat);
        engin.setCapacite(capacite);

        return enginRepository.save(engin);
    }

    public Engin updateEngin(
            Long enginId,
            EtatEngin nouvelEtat
    ) {

        getAdminConnecte();

        Engin engin = enginRepository.findById(enginId)
                .orElseThrow(() ->
                        new RuntimeException("Engin introuvable"));

        engin.setEtat(nouvelEtat);

        return enginRepository.save(engin);
    }

    public void deleteEngin(
            Long enginId
    ) {

        getAdminConnecte();

        Engin engin = enginRepository.findById(enginId)
                .orElseThrow(() ->
                        new RuntimeException("Engin introuvable"));

        enginRepository.delete(engin);
    }

    public List<Engin> getAllEngins() {

        getAdminConnecte();

        return enginRepository.findAll();
    }

      /// =====================================================
     /// GESTION DES POSTES
    /// =====================================================

    public Poste createPoste(
            Integer numeroPoste,
            String localisation,
            Double latitude,
            Double longitude
    ) {

        getAdminConnecte();

        Poste poste = new Poste();

        poste.setNumeroPoste(numeroPoste);
        poste.setLocalisation(localisation);
        poste.setLatitude(latitude);
        poste.setLongitude(longitude);
        return posteRepository.save(poste);
    }

    public Poste updatePoste(
            Long posteId,
            Integer numeroPoste,
            String localisation,
            Double latitude,
            Double longitude
    ) {

        getAdminConnecte();

        Poste poste = posteRepository.findById(posteId)
                .orElseThrow(() ->
                        new RuntimeException("Poste introuvable"));

        poste.setNumeroPoste(numeroPoste);
        poste.setLocalisation(localisation);
        poste.setLatitude(latitude);
        poste.setLongitude(longitude);

        return posteRepository.save(poste);
    }

    public void deletePoste(
            Long posteId
    ) {

        getAdminConnecte();

        Poste poste = posteRepository.findById(posteId)
                .orElseThrow(() ->
                        new RuntimeException("Poste introuvable"));

        posteRepository.delete(poste);
    }

    public List<Poste> getAllPostes() {

        getAdminConnecte();

        return posteRepository.findAll();
    }


    /// =====================================================
   /// GESTION DES PORTIERS
  /// =====================================================

    public Portier createPortier(
            String code,
            Integer nombreCameras
    ) {

        getAdminConnecte();

        Portier portier = new Portier();

        portier.setCode(code);
        portier.setNombreCameras(nombreCameras);

        return portierRepository.save(portier);
    }

    public Portier updatePortier(
            Long portierId,
            Integer nbCameras
    ) {

        getAdminConnecte();

        Portier portier = portierRepository.findById(portierId)
                .orElseThrow(() ->
                        new RuntimeException("Portier introuvable"));

        portier.setNombreCameras(nbCameras);

        return portierRepository.save(portier);
    }

    public void deletePortier(
            Long portierId
    ) {

        getAdminConnecte();

        Portier portier = portierRepository.findById(portierId)
                .orElseThrow(() ->
                        new RuntimeException("Portier introuvable"));

        portierRepository.delete(portier);
    }

    public List<Portier> getAllPortiers() {

        getAdminConnecte();

        return portierRepository.findAll();
    }


      /// =====================================================
    /// GESTION DES Navires
   /// =====================================================

    public Navire createNavire(String nom, String numeroIMO) {

        getAdminConnecte();

        if (navireRepository.existsByNumeroIMO(numeroIMO)) {
            throw new RuntimeException("Navire déjà existant");
        }

        Navire navire = new Navire();
        navire.setNom(nom);
        navire.setNumeroIMO(numeroIMO);

        return navireRepository.save(navire);
    }

    public Navire updateNavire(Long navireId, String nom, String numeroIMO) {

        getAdminConnecte();

        Navire navire = navireRepository.findById(navireId)
                .orElseThrow(() -> new RuntimeException("Navire introuvable"));

        // éviter duplication IMO
        if (!navire.getNumeroIMO().equals(numeroIMO)
                && navireRepository.existsByNumeroIMO(numeroIMO)) {
            throw new RuntimeException("Numero IMO déjà utilisé");
        }

        navire.setNom(nom);
        navire.setNumeroIMO(numeroIMO);

        return navireRepository.save(navire);
    }

    public List<Navire> getAllNavires() {

        getAdminConnecte();

        return navireRepository.findAll();
    }

    public Navire getNavireById(Long id) {

        getAdminConnecte();

        return navireRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Navire introuvable"));
    }


    public void deleteNavire(Long navireId) {

        getAdminConnecte();

        Navire navire = navireRepository.findById(navireId)
                .orElseThrow(() -> new RuntimeException("Navire introuvable"));

        navireRepository.delete(navire);
    }


      /// =====================================================
     /// GESTION DES ESCALES
    /// =====================================================

      public Escale createEscale(
              String numeroEscale,
              LocalDate dateArrivee,
              LocalDate dateDepart,
              Long navireId
      ) {

          getAdminConnecte();

          Navire navire = navireRepository.findById(navireId)
                  .orElseThrow(() -> new RuntimeException("Navire introuvable"));

          if (dateDepart.isBefore(dateArrivee)) {
              throw new RuntimeException("Dates invalides");
          }

          Escale escale = new Escale();
          escale.setNumeroEscale(numeroEscale);
          escale.setDateArrivee(dateArrivee);
          escale.setDateDepart(dateDepart);
          escale.setNavire(navire);

          return escaleRepository.save(escale);
      }

    public Escale updateEscale(
            Long escaleId,
            String numeroEscale,
            LocalDate dateArrivee,
            LocalDate dateDepart,
            Long navireId
    ) {

        getAdminConnecte();

        Escale escale = escaleRepository.findById(escaleId)
                .orElseThrow(() -> new RuntimeException("Escale introuvable"));

        Navire navire = navireRepository.findById(navireId)
                .orElseThrow(() -> new RuntimeException("Navire introuvable"));

        if (dateDepart.isBefore(dateArrivee)) {
            throw new RuntimeException("Dates invalides");
        }

        escale.setNumeroEscale(numeroEscale);
        escale.setDateArrivee(dateArrivee);
        escale.setDateDepart(dateDepart);
        escale.setNavire(navire);

        return escaleRepository.save(escale);
    }

    public void deleteEscale(Long escaleId) {

        getAdminConnecte();

        Escale escale = escaleRepository.findById(escaleId)
                .orElseThrow(() -> new RuntimeException("Escale introuvable"));

        escaleRepository.delete(escale);
    }

    public List<Escale> getAllEscales() {

        getAdminConnecte();

        return escaleRepository.findAll();
    }

    public List<Escale> getEscalesByNavire(Long navireId) {

        getAdminConnecte();

        return escaleRepository.findByNavireId(navireId);
    }



    /// ******************************** Statistiques ************************* //

    public AdminDashboardStats getDashboardStats() {

        getAdminConnecte();

        long totalPersonnels =
                personnelRepository.count();

        long totalChefsEscales =
                personnelRepository.countByRole(
                        RolePersonnel.CHEF_ESCALE
                );

        long totalChefsService =
                personnelRepository.countByRole(
                        RolePersonnel.CHEF_SERVICE
                );

        long totalChefsDivision =
                personnelRepository.countByRole(
                        RolePersonnel.CHEF_DIVISION
                );

        long totalEquipes =
                equipeRepository.count();

        long totalShifts =
                shiftRepository.count();

        long shiftsActifs =
                shiftRepository.countByPlanningJour_Date(
                        LocalDate.now()
                );

        long demandesEnAttente =
                demandeRepository.countByStatut(
                        StatutDemande.EN_ATTENTE
                );

        long employesEnConge =
                congesRepository
                        .countByDateDebutLessThanEqualAndDateFinGreaterThanEqual(
                                LocalDate.now(),
                                LocalDate.now()
                        );

        return new AdminDashboardStats(
                totalPersonnels,
                totalChefsEscales,
                totalChefsService,
                totalChefsDivision,
                totalEquipes,
                totalShifts,
                shiftsActifs,
                demandesEnAttente,
                employesEnConge
        );
    }

    /// ================ Statistiques engins =================
    public List<ResourceUsageDTO> getMostUsedEngins() {

        getAdminConnecte();

        return operationRepository.getMostUsedEngins();
    }

    public List<Engin> getUnusedEnginsStats() {
        getAdminConnecte();
        return enginRepository.getUnusedEngins();
    }

    public List<Engin> getBrokenEnginsStats() {
        getAdminConnecte();
        return enginRepository.findByEtat(
                EtatEngin.PANNE
        );
    }

    public List<StatsRateDTO> getEnginsUsageRateStats() {
        getAdminConnecte();
        return operationRepository.getEnginsUsageRate();
    }
    /// ================ Statistiques postes =================

    public List<ResourceUsageDTO> getMostUsedPostes() {

        getAdminConnecte();

        return operationRepository.getMostUsedPostes();
    }


    public List<Poste> getUnusedPostesStats() {
        getAdminConnecte();
        return posteRepository.getUnusedPostes();
    }

    /// ================ Statistiques portiers =================

    public List<ResourceUsageDTO> getMostUsedPortiers() {

        getAdminConnecte();

        return operationRepository.getMostUsedPortiers();
    }


    public List<StatsCountDTO> getContainersByPortierStats() {
        getAdminConnecte();
        return operationRepository.getContainersByPortier();
    }


    public OperationStatsDTO getOperationStats() {

        getAdminConnecte();

        long total =
                operationRepository.count();

        long terminees =
                operationRepository.countByStatut(
                        StatutOperation.TERMINE
                );

        long enCours =
                operationRepository.countByStatut(
                        StatutOperation.EN_COURS
                );

        long pauses =
                operationRepository.countByStatut(
                        StatutOperation.PAUSE
                );

        Double moyenneConteneurs =
                operationRepository.getAverageContainers();

        Double dureeMoyenne =
                operationRepository.getAverageOperationDuration();

        return new OperationStatsDTO(
                total,
                terminees,
                enCours,
                pauses,
                moyenneConteneurs,
                dureeMoyenne
        );
    }

    public long getActiveEscales() {

        getAdminConnecte();

        LocalDate today = LocalDate.now();

        return escaleRepository
                .findAll()
                .stream()
                .filter(e ->
                        !e.getDateArrivee().isAfter(today)
                                && !e.getDateDepart().isBefore(today)
                )
                .count();
    }

    public long getActiveNavires() {

        getAdminConnecte();

        LocalDate today = LocalDate.now();

        return escaleRepository
                .findAll()
                .stream()
                .filter(e ->
                        !e.getDateArrivee().isAfter(today)
                                && !e.getDateDepart().isBefore(today)
                )
                .map(e -> e.getNavire().getId())
                .distinct()
                .count();
    }

}