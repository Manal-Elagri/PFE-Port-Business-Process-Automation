package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.Notification;
import Projet_Stage.PFE.enums.StatutNotification;
import Projet_Stage.PFE.enums.TypeNotification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    // Notifications d’un personnel
    List<Notification> findByPersonnelId(Long personnelId);

    // Notifications d’une opération
    List<Notification> findByOperationId(Long operationId);

    // Filtrer par type (EMAIL / WHATSAPP)
    List<Notification> findByType(TypeNotification type);

    // Filtrer par statut (ENVOYE / ECHEC)
    List<Notification> findByStatut(StatutNotification statut);

    // Historique complet d’un utilisateur
    List<Notification> findByPersonnelIdOrderByDateEnvoiDesc(Long personnelId);
}