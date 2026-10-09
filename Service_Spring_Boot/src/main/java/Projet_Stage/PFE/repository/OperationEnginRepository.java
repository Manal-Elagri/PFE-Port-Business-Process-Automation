package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.OperationEngin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OperationEnginRepository extends JpaRepository<OperationEngin, Long> {

    List<OperationEngin> findByOperationId(Long operationId);

    @Query("""
        SELECT
        oe.engin.id,
        oe.engin.type,
        COUNT(oe)
        FROM OperationEngin oe
        GROUP BY oe.engin.id, oe.engin.type
        ORDER BY COUNT(oe) DESC
    """)
    List<Object[]> getMostUsedEngins();


    @Query("""
        SELECT
        oe.engin.id,
        oe.engin.type,
        COUNT(oe)
        FROM OperationEngin oe
        GROUP BY oe.engin.id, oe.engin.type
    """)
    List<Object[]> getOperationsByEngin();


    @Query("""
        SELECT
        oe.engin.id,
        oe.engin.type,
        (COUNT(oe) * 100.0 /
            (SELECT COUNT(o)
             FROM Operation o)
        )
        FROM OperationEngin oe
        GROUP BY oe.engin.id, oe.engin.type
    """)
    List<Object[]> getUsageRateByEngin();

}
