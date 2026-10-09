package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.Poste;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PosteRepository extends JpaRepository<Poste, Long> {

    @Query("""
    SELECT p
    FROM Poste p
    WHERE p.id NOT IN (
    SELECT DISTINCT o.poste.id
    FROM Operation o
    WHERE o.poste IS NOT NULL
)
""")
    List<Poste> getUnusedPostes();
}
