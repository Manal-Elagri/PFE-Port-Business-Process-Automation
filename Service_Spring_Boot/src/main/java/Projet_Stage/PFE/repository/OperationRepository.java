package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.dto.ResourceUsageDTO;
import Projet_Stage.PFE.dto.StatsCountDTO;
import Projet_Stage.PFE.dto.StatsRateDTO;
import Projet_Stage.PFE.entities.Engin;
import Projet_Stage.PFE.entities.Operation;
import Projet_Stage.PFE.entities.Poste;
import Projet_Stage.PFE.enums.StatutOperation;
import Projet_Stage.PFE.enums.TypeOperation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface OperationRepository extends JpaRepository<Operation, Long> {

    // Récupérer toutes les opérations EN_COURS
    List<Operation> findByStatut(StatutOperation statut);

    @Query("""
    SELECT DISTINCT o
    FROM Operation o
    LEFT JOIN FETCH o.escale
    LEFT JOIN FETCH o.shift
    LEFT JOIN FETCH o.poste
    LEFT JOIN FETCH o.portier
    LEFT JOIN FETCH o.equipe
    WHERE o.id = :id
""")
    Optional<Operation> findByIdWithBaseRelations(@Param("id") Long id);


    @Query("""
    SELECT DISTINCT o
    FROM Operation o
    LEFT JOIN FETCH o.arrets
    WHERE o.id = :id
""")
    Optional<Operation> findByIdWithArrets(@Param("id") Long id);


    @Query("""
    SELECT DISTINCT o
    FROM Operation o
    LEFT JOIN FETCH o.operationEngins oe
    LEFT JOIN FETCH oe.engin
    WHERE o.id = :id
""")
    Optional<Operation> findByIdWithEngins(@Param("id") Long id);
    @Query("""
    SELECT new Projet_Stage.PFE.dto.ResourceUsageDTO(
    oe.engin.type,
    COUNT(oe.id)
    )
    FROM OperationEngin oe
    GROUP BY oe.engin.id, oe.engin.type
    ORDER BY COUNT(oe.id) DESC
    """)
    List<ResourceUsageDTO> getMostUsedEngins();


    @Query("""
    SELECT new Projet_Stage.PFE.dto.StatsRateDTO(
    oe.engin.type,
    (COUNT(oe.id) * 100.0 /
        (SELECT COUNT(o.id) FROM Operation o)
    )
    )
    FROM OperationEngin oe
    GROUP BY oe.engin.id, oe.engin.type
    """)
    List<StatsRateDTO> getEnginsUsageRate();

    @Query("""
    SELECT new Projet_Stage.PFE.dto.ResourceUsageDTO(
    CONCAT('Poste ', CAST(o.poste.numeroPoste as string)),
    COUNT(o.id)
    )
    FROM Operation o
    WHERE o.poste IS NOT NULL
    GROUP BY o.poste.id, o.poste.numeroPoste
    ORDER BY COUNT(o.id) DESC
    """)
    List<ResourceUsageDTO> getMostUsedPostes();


    @Query("""
    SELECT new Projet_Stage.PFE.dto.ResourceUsageDTO(
    o.portier.code,
    COUNT(o.id)
    )
    FROM Operation o
    WHERE o.portier IS NOT NULL
    GROUP BY o.portier.id, o.portier.code
    ORDER BY COUNT(o.id) DESC
    """)
    List<ResourceUsageDTO> getMostUsedPortiers();

    @Query("""
    SELECT new Projet_Stage.PFE.dto.StatsCountDTO(
      o.portier.code,
      SUM(o.nombreConteneurs)
    )
    FROM Operation o
    WHERE o.portier IS NOT NULL
    GROUP BY o.portier.id, o.portier.code
    """)
    List<StatsCountDTO> getContainersByPortier();

    @Query("""
    SELECT AVG(o.nombreConteneurs)
    FROM Operation o
    """)
    Double getAverageContainers();

    @Query(value = """
    SELECT AVG(
    TIMESTAMPDIFF(MINUTE, date_debut, date_fin)
    )
    FROM operation
    WHERE date_fin IS NOT NULL
    """, nativeQuery = true)
    Double getAverageOperationDuration();

    long countByStatut(
            StatutOperation statut
    );


    // ================= CHEF SERVICE =================

    long countByShiftId(
            Long shiftId
    );

    long countByShiftIdAndStatut(
            Long shiftId,
            StatutOperation statut
    );

    @Query("""
            SELECT COUNT(DISTINCT o.poste.id)
            FROM Operation o
            WHERE o.shift.id=:shiftId
            """)
    long countUsedPostes(
            @Param("shiftId") Long shiftId
    );

    @Query("""
            SELECT COUNT(DISTINCT o.portier.id)
            FROM Operation o
            WHERE o.shift.id=:shiftId
            """)
    long countUsedPortiers(
            @Param("shiftId") Long shiftId
    );

    @Query("""
            SELECT COUNT(DISTINCT oe.engin.id)
            FROM OperationEngin oe
            WHERE oe.operation.shift.id=:shiftId
            """)
    long countUsedEngins(
            @Param("shiftId") Long shiftId
    );

    @Query("""
            SELECT COALESCE(SUM(o.nombreConteneurs),0)
            FROM Operation o
            WHERE o.shift.id=:shiftId
            """)
    long totalContainers(
            @Param("shiftId") Long shiftId
    );

    @Query("""
            SELECT AVG(o.nombreConteneurs)
            FROM Operation o
            WHERE o.shift.id=:shiftId
            """)
    Double avgContainers(
            @Param("shiftId") Long shiftId
    );

    @Query("""
            SELECT AVG(
                TIMESTAMPDIFF(
                    MINUTE,
                    o.dateDebut,
                    o.dateFin
                )
            )
            FROM Operation o
            WHERE o.shift.id=:shiftId
            AND o.dateFin IS NOT NULL
            """)
    Double avgDuration(
            @Param("shiftId") Long shiftId
    );


    // ================= CHEF DIVISION =================

    long countByDateDebutAfter(
            LocalDateTime date
    );

    long countByType(
            TypeOperation type
    );


    @Query("""
SELECT
CASE
WHEN COUNT(o)=0 THEN 0
ELSE (
SUM(CASE WHEN o.statut = 'TERMINE' THEN 1 ELSE 0 END) * 100.0 / COUNT(o)
)
END
FROM Operation o
""")
    Double calculateRetardRate();



    @Query("""
    SELECT
    o.escale.numeroEscale,
    o.escale.navire.nom,
    COUNT(o)
    FROM Operation o
    GROUP BY
    o.escale.numeroEscale,
    o.escale.navire.nom
    ORDER BY COUNT(o) DESC
""")
    List<Object[]> getOperationsByEscale();

    @Query("""
    SELECT
    o.escale.numeroEscale,
    o.escale.navire.nom,
    COUNT(o)
    FROM Operation o
    GROUP BY
    o.escale.numeroEscale,
    o.escale.navire.nom
""")
    List<Object[]> getEscalesStats();


    @Query("""
    SELECT
    o.escale.navire.nom,
    COUNT(o)
    FROM Operation o
    GROUP BY o.escale.navire.nom
    ORDER BY COUNT(o) DESC
""")
    List<Object[]> getTopNavires();


    @Query("""
    SELECT
    o.equipe.id,
    o.equipe.matriculeEquipe,
    COUNT(o),
    SUM(o.nombreConteneurs)
    FROM Operation o
    WHERE o.equipe IS NOT NULL
    GROUP BY o.equipe.id, o.equipe.matriculeEquipe
    ORDER BY SUM(o.nombreConteneurs) DESC
    """)
    List<Object[]> getBestTeams();

    long countByEquipeId(Long equipeId);

    long countByEquipeIdAndStatut(
            Long equipeId,
            StatutOperation statut
    );

    @Query("""
    SELECT COALESCE(
    SUM(o.nombreConteneurs),0
    )
    FROM Operation o
    WHERE o.equipe.id=:equipeId
    """)
    Long totalContainersByEquipe(Long equipeId);

    @Query("""
    SELECT COALESCE(
    AVG(o.nombreConteneurs),0
    )
    FROM Operation o
    WHERE o.equipe.id=:equipeId
    """)
    Double avgContainersByEquipe(Long equipeId);

    @Query("""
    SELECT COALESCE(AVG(
        CAST(FUNCTION('TIMESTAMPDIFF', MINUTE, o.dateDebut, o.dateFin) AS double)
    ), 0.0)
    FROM Operation o
    WHERE o.equipe.id = :equipeId
    AND o.dateFin IS NOT NULL
    """)
    Double avgOperationDurationByEquipe(@Param("equipeId") Long equipeId);

    @Query("""
    SELECT
    CASE
    WHEN COUNT(o)=0 THEN 0
    ELSE (
    SUM(
    CASE
    WHEN o.statut='TERMINE'
    THEN 1
    ELSE 0
    END
    ) * 100.0 / COUNT(o)
    )
    END
    FROM Operation o
    WHERE o.equipe.id = :equipeId
    """)
    Double successRateByEquipe(
            @Param("equipeId") Long equipeId
    );


    List<Operation> findByEquipeIdOrderByDateDebutDesc(
            Long equipeId
    );


}
