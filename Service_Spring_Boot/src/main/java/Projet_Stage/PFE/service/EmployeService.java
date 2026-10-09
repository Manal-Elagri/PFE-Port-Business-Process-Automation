package Projet_Stage.PFE.service;

import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.enums.RolePersonnel;
import Projet_Stage.PFE.enums.RoleUser;
import Projet_Stage.PFE.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
@Service
@RequiredArgsConstructor
public class EmployeService {


    private final EquipePersonnelRepository equipePersonnelRepository;
    private final HistoriqueShiftRepository historiqueShiftRepository;
    private final CongesRepository congesRepository;


    // =====================================================
    // Employé CONNECTÉ
    // =====================================================
    public Personnel getEmployeConnecte() {

        User user = getCurrentUser();

        if (!RoleUser.EMPLOYE.equals(user.getRole())) {
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
    /// ==================== Gestion Des congés Pour Tout Le personnel ==================

    private Conges getMyConge(Long  congeId) {

        Personnel chef = getEmployeConnecte();

        Conges congés = congesRepository.findById(congeId)
                .orElseThrow(() ->
                        new RuntimeException("Congé  introuvable"));

        return congés;
    }
    /**
     * 📝 Demander un congé
     */
    public Conges demanderConge( LocalDate dateDebut, LocalDate dateFin , Conges.TypeCong type) {
        Personnel employe = getEmployeConnecte();

        Conges conge = new Conges();
        conge.setEmploye(employe);
        conge.setDateDebut(dateDebut);
        conge.setDateFin(dateFin);
        conge.setStatut(Conges.StatutConge.EN_ATTENTE);
        conge.setType(type);
        return congesRepository.save(conge);
    }

    /**
     * ✏️ Modifier une demande de congé (si EN_ATTENTE)
     */
    public Conges modifierDemandeConge(Long congeId, LocalDate newDateDebut, LocalDate newDateFin , Conges.TypeCong type) {

        Conges conge = getMyConge(congeId);

        if (conge.getStatut() != Conges.StatutConge.EN_ATTENTE) {
            throw new RuntimeException("Impossible de modifier une demande déjà traitée !");
        }

        conge.setDateDebut(newDateDebut);
        conge.setDateFin(newDateFin);
        conge.setType(type);

        return congesRepository.save(conge);
    }

    /**
     * ❌ Supprimer une demande de congé (si EN_ATTENTE)
     */
    public boolean supprimerDemandeConge(Long congeId) {
        Conges conge = getMyConge(congeId);

        if (conge.getStatut() != Conges.StatutConge.EN_ATTENTE) {
            throw new RuntimeException("Impossible de supprimer une demande déjà traitée !");
        }

        congesRepository.delete(conge);
        return true;
    }

    /**
     * 📋 Récupérer les congés d’un employé
     */
    public List<Conges> getCongesByEmploye() {
        Personnel employe = getEmployeConnecte();
        return congesRepository.findByEmployeId(employe.getId());
    }


    /// =========== Mes Affectations ===========

    public List<EquipePersonnel> getMyAssignments() {

        Personnel employe = getEmployeConnecte();

        return equipePersonnelRepository
                .findByPersonnelId(employe.getId());
    }

    public List<EquipePersonnel> getMyAssignmentsByShift(Long shiftId) {

        Personnel employe = getEmployeConnecte();

        return equipePersonnelRepository
                .findByPersonnelIdAndEquipe_Shift_Id(
                        employe.getId(),
                        shiftId
                );
    }

    public List<EquipePersonnel> getMyAssignmentsByEquipe(Long equipeId) {

        Personnel employe = getEmployeConnecte();

        return equipePersonnelRepository
                .findByPersonnelIdAndEquipe_Id(
                        employe.getId(),
                        equipeId
                );
    }

    public List<EquipePersonnel> getMyShiftCalendar() {

        Personnel employe = getEmployeConnecte();

        return equipePersonnelRepository
                .findByPersonnelId(employe.getId());
    }

    public List<HistoriqueShift> getMyHistory() {

        Personnel employe = getEmployeConnecte();

        return historiqueShiftRepository
                .findByPersonnelId(
                        employe.getId()
                );
    }

    /// ========== Vérifier si le bouton “Démarrer opération” doit apparaître ==============

    public boolean canStartOperation() {
        try {
            Personnel personnel = getEmployeConnecte();

            System.out.println("=== DEBUG canStartOperation ===");
            System.out.println("Personnel ID = " + personnel.getId());
            System.out.println("Personnel role = " + personnel.getRole());

            EquipePersonnel ep = equipePersonnelRepository
                    .findFirstByPersonnelId(personnel.getId())
                    .orElse(null);

            if (ep == null) {
                System.out.println("ECHEC: personnel non affecté à une équipe");
                return false;
            }

            System.out.println("EquipePersonnel ID = " + ep.getId());
            System.out.println("Role métier = " + ep.getRoleMetier());

            if (personnel.getRole() != RolePersonnel.POINTEUR) {
                System.out.println("ECHEC: role métier différent de POINTEUR");
                return false;
            }

            Equipe equipe = ep.getEquipe();

            if (equipe == null) {
                System.out.println("ECHEC: équipe null");
                return false;
            }

            System.out.println("Equipe ID = " + equipe.getId());
            System.out.println("Equipe matricule = " + equipe.getMatriculeEquipe());

            if (equipe.getShift() == null) {
                System.out.println("ECHEC: shift null");
                return false;
            }

            Shift shift = equipe.getShift();

            System.out.println("Shift ID = " + shift.getId());
            System.out.println("Heure début = " + shift.getHeureDebut());
            System.out.println("Heure fin = " + shift.getHeureFin());

            LocalTime now = LocalTime.now();

            System.out.println("Heure actuelle serveur = " + now);

            boolean inShift = isNowInShift(
                    now,
                    shift.getHeureDebut(),
                    shift.getHeureFin()
            );

            System.out.println("In shift = " + inShift);

            if (!inShift) {
                System.out.println("ECHEC: heure actuelle hors shift");
                return false;
            }

            if (equipe.getPlanningJour() == null) {
                System.out.println("ECHEC: planningJour null");
                return false;
            }

            LocalDate today = LocalDate.now();
            LocalDate planningDate = equipe.getPlanningJour().getDate();

            System.out.println("Date serveur = " + today);
            System.out.println("Date planning = " + planningDate);

            if (!today.equals(planningDate)) {
                System.out.println("ECHEC: planning pas aujourd'hui");
                return false;
            }

            System.out.println("SUCCES: peut lancer opération");
            return true;

        } catch (Exception e) {
            System.out.println("ERREUR canStartOperation = " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private boolean isNowInShift(LocalTime now, LocalTime debut, LocalTime fin) {
        if (now == null || debut == null || fin == null) {
            return false;
        }

        if (debut.equals(fin)) {
            return true;
        }

        // Shift normal : 00:00 -> 08:00
        if (debut.isBefore(fin)) {
            return !now.isBefore(debut) && now.isBefore(fin);
        }

        // Shift qui traverse minuit : 16:00 -> 00:00 ou 22:00 -> 06:00
        return !now.isBefore(debut) || now.isBefore(fin);
    }

    public Equipe getMyCurrentOperationContext() {

        Personnel employe = getEmployeConnecte();

        if (employe.getRole() != RolePersonnel.POINTEUR) {
            throw new RuntimeException("Accès refusé");
        }

        EquipePersonnel affectation =
                equipePersonnelRepository
                        .findFirstByPersonnelId(
                                employe.getId()
                        )
                        .orElseThrow(() ->
                                new RuntimeException("Aucune affectation"));

        return affectation.getEquipe();
    }


}
