package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.Conges;
import Projet_Stage.PFE.enums.RoleUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface CongesRepository extends JpaRepository<Conges, Long> {

    // Récupérer les congés selon un jour
    List<Conges> findByDateDebutLessThanEqualAndDateFinGreaterThanEqual(LocalDate date, LocalDate date2);

    // Récupérer les congés par mois (exemple janvier 2025 -> 2025-01-01 à 2025-01-31)
    List<Conges> findByDateDebutBetween(LocalDate start, LocalDate end);

    List<Conges> findByEmployeId(Long employeId);


    long countByDateDebutLessThanEqualAndDateFinGreaterThanEqual(
            LocalDate debut,
            LocalDate fin
    );


    // absents aujourd'hui
    long countByDateDebutLessThanEqualAndDateFinGreaterThanEqualAndStatut(
            LocalDate start,
            LocalDate end,
            Conges.StatutConge statut
    );

    // par statut
    long countByStatut(
            Conges.StatutConge statut
    );

    // par type
    long countByType(
            Conges.TypeCong type
    );

    // par rôle
    @Query("""
            SELECT COUNT(c)
            FROM Conges c
            WHERE c.statut='ACCEPTE'
            AND c.dateDebut<=:today
            AND c.dateFin>=:today
            AND c.employe.role=:role
            """)
    long countAbsentByRole(
            @Param("today") LocalDate today,
            @Param("role") RoleUser role
    );


    @Query("""
    SELECT COUNT(c)
    FROM Conges c
    JOIN EquipePersonnel ep
        ON ep.personnel.id = c.employe.id
    WHERE ep.equipe.id = :equipeId
    AND c.dateDebut <= :today
    AND c.dateFin >= :today
    AND c.statut = :statut
""")
    long countAbsentByEquipe(
            Long equipeId,
            LocalDate today,
            Conges.StatutConge statut
    );

    List<Conges> findByEmployeIdOrderByDateDebutDesc(
            Long employeId
    );

    List<Conges> findByEmploye_Equipe_IdAndDateDebutLessThanEqualAndDateFinGreaterThanEqualAndStatut(
            Long equipeId,
            LocalDate start,
            LocalDate end,
            Conges.StatutConge statut
    );
}
