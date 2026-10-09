package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.Arret;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ArretRepository extends JpaRepository<Arret, Long> {

    long count();
    // Vérifie s'il existe un arrêt en cours
    boolean existsByOperationIdAndDateFinIsNull(Long operationId);
    List<Arret> findByOperationIdAndDateFinIsNull(Long operationId);

    @Query("SELECT COUNT(a) FROM Arret a WHERE a.operation.shift.id = :shiftId")
    long countByShift(@Param("shiftId") Long shiftId);

    // CORRECTION POSTGRES : Moyenne durée par Shift
    @Query(value = """
            SELECT COALESCE(AVG(EXTRACT(EPOCH FROM (a.date_fin - a.date_debut)) / 60), 0)
            FROM arret a
            JOIN operation o ON a.operation_id = o.id
            WHERE o.shift_id = :shiftId
            """, nativeQuery = true)
    Double totalArretDuration(@Param("shiftId") Long shiftId);

    @Query("""
    SELECT CASE WHEN COUNT(a) = 0 THEN 0.0 ELSE 100.0 END FROM Arret a
    """)
    double calculateArretRate();

    // CORRECTION POSTGRES : Moyenne durée globale
    @Query(value = """
            SELECT COALESCE(AVG(EXTRACT(EPOCH FROM (a.date_fin - a.date_debut)) / 60), 0)
            FROM arret a
            """, nativeQuery = true)
    double avgArretDuration();

    @Query("""
    SELECT a.cause.libelle, COUNT(a)
    FROM Arret a
    GROUP BY a.cause.libelle
    ORDER BY COUNT(a) DESC
    """)
    List<Object[]> topCausesArret();

    @Query("""
    SELECT COUNT(DISTINCT a.operation) * 100.0 /
    NULLIF((SELECT COUNT(o) FROM Operation o), 0)
    FROM Arret a
    """)
    double tauxBlocageOperations();

    // CORRECTION POSTGRES : Somme totale temps perdu
    @Query(value = """
            SELECT COALESCE(SUM(EXTRACT(EPOCH FROM (a.date_fin - a.date_debut)) / 60), 0)
            FROM arret a
            """, nativeQuery = true)
    long tempsPerduTotal();

    long countByDateDebutBetween(LocalDateTime start, LocalDateTime end);

    @Query("SELECT COUNT(a) FROM Arret a WHERE a.operation.equipe.id = :equipeId")
    long countByEquipe(@Param("equipeId") Long equipeId);

    // CORRECTION POSTGRES : Somme temps perdu par Équipe
    @Query(value = """
            SELECT COALESCE(SUM(EXTRACT(EPOCH FROM (a.date_fin - a.date_debut)) / 60), 0)
            FROM arret a
            JOIN operation o ON a.operation_id = o.id
            WHERE o.equipe_id = :equipeId
            """, nativeQuery = true)
    Long tempsPerduByEquipe(@Param("equipeId") Long equipeId);
}