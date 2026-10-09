package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.Shift;
import Projet_Stage.PFE.enums.TypeShift;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ShiftRepository extends JpaRepository<Shift, Long> {

    boolean existsByPlanningJourIdAndType(
            Long planningId,
            TypeShift type
    );


    List<Shift> findByPlanningJour_Date(LocalDate date);

    long countByPlanningJour_Date(
            LocalDate date
    );

    List<Shift> findByPlanningJourId(Long planningJourId);

}