package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.HistoriqueShift;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface HistoriqueShiftRepository extends JpaRepository<HistoriqueShift, Long> {

    List<HistoriqueShift> findByShiftId(Long shiftId);

    // affectation active d'une équipe
    Optional<HistoriqueShift> findByEquipeIdAndActiveTrue(
            Long equipeId
    );

    // historique d'une équipe
    List<HistoriqueShift> findByEquipeIdOrderByDateDebutDesc(
            Long equipeId
    );

    // historique d'un shift
    List<HistoriqueShift> findByShiftIdOrderByDateDebutDesc(
            Long shiftId
    );

    // période dashboard
    List<HistoriqueShift> findByDateDebutBetween(
            LocalDateTime start,
            LocalDateTime end
    );

    @Query("""
    SELECT h
    FROM HistoriqueShift h
    JOIN h.equipe e
    JOIN e.equipePersonnels ep
    JOIN ep.personnel p
    WHERE p.id = :personnelId
    ORDER BY h.dateDebut DESC
    """)
    List<HistoriqueShift> findByPersonnelId(@Param("personnelId") Long personnelId);


    List<HistoriqueShift> findAllByOrderByDateDebutDesc();
    List<HistoriqueShift> findByChefEscaleIdOrderByDateDebutDesc(Long id);


    long countByChefEscaleId(
            Long chefEscaleId
    );

    @Query("""
        SELECT COUNT(DISTINCT h.shift.id)
        FROM HistoriqueShift h
        WHERE h.chefEscale.id = :chefId
    """)
    long countDistinctShiftsByChefEscale(
            Long chefId
    );
}
