package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.Equipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface EquipeRepository extends JpaRepository<Equipe, Long> {

    List<Equipe> findByShiftId(Long shiftId);
    List<Equipe> findByChefEscaleId(Long chefId);

    long countByChefEscaleId(
            Long chefEscaleId
    );

    @Query("""
    SELECT e FROM Equipe e
    WHERE e.shift.planningJour.date = :date
    """)
    List<Equipe> findActiveTeamsToday(LocalDate date);

    Optional<Equipe> findByChefEquipeId(Long chefId);


}
