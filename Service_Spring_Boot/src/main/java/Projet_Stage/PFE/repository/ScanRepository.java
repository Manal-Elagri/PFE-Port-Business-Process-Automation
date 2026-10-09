package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.Scan;
import Projet_Stage.PFE.enums.StatutValidationScan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ScanRepository extends JpaRepository<Scan, Long> {

    // Récupérer tous les scans d'une opération
    List<Scan> findByOperationId(Long operationId);

    // CORRECTION : s.dateHeure devient s.date
    @Query("SELECT MAX(s.date) FROM Scan s WHERE s.operation.id = :operationId")
    LocalDateTime findLastScanTime(@Param("operationId") Long operationId);

    boolean existsByOperationIdAndMatriculeDetecte(
            Long operationId,
            String matricule
    );

    boolean existsByMobileScanId(
            String mobileScanId
    );

    Long countByOperationId(Long operationId);

    long countByDateAfter(LocalDateTime date);

    /**
     * CORRECTION : detecteCorrectement n'existe pas.
     * On utilise le statutValidationScan.
     * Si le statut est 'VALIDE', on compte 100%, sinon 0%.
     */
    @Query("""
            SELECT AVG(
                CASE 
                    WHEN s.statutValidationScan = Projet_Stage.PFE.enums.StatutValidationScan.VALIDE 
                    THEN 100.0 
                    ELSE 0.0 
                END
            ) 
            FROM Scan s
            """)
    Double detectionRate();

    // CORRECTION : s.scoreConfiance (le nom doit être identique à l'entité)
    @Query("""
    SELECT COUNT(s)
    FROM Scan s
    WHERE s.scoreConfiance < 70
    """)
    long countErrors();


    boolean existsByOperationIdAndMatriculeDetecteAndIdNot(
            Long operationId,
            String matriculeDetecte,
            Long scanId
    );

    boolean existsByOperationIdAndMatriculeDetecteAndStatutValidationScan(
            Long operationId,
            String matriculeDetecte,
            StatutValidationScan statutValidationScan
    );

    boolean existsByOperationIdAndMatriculeDetecteAndStatutValidationScanAndIdNot(
            Long operationId,
            String matriculeDetecte,
            StatutValidationScan statutValidationScan,
            Long id
    );

}