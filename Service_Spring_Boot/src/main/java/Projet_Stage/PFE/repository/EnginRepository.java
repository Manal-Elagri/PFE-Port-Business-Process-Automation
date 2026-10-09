package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.Engin;
import Projet_Stage.PFE.enums.EtatEngin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EnginRepository extends JpaRepository<Engin, Long> {

    List<Engin> findByEtat(EtatEngin etat);

    @Query("""
    SELECT e
    FROM Engin e
    WHERE e.id NOT IN (
    SELECT DISTINCT oe.engin.id
    FROM OperationEngin oe
    )
    """)
    List<Engin> getUnusedEngins();

}
