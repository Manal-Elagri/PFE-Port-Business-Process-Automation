package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.Equipe;
import Projet_Stage.PFE.entities.EquipePersonnel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EquipePersonnelRepository extends JpaRepository<EquipePersonnel, Long> {

    boolean existsByEquipeIdAndPersonnelId(
            Long equipeId,
            Long personnelId
    );

    boolean existsByPersonnelIdAndEquipe_Shift_Id(
            Long personnelId,
            Long shiftId
    );

    List<EquipePersonnel> findByPersonnelIdAndEquipe_Shift_Id(
            Long personnelId,
            Long shiftId
    );

    List<EquipePersonnel> findByPersonnelIdAndEquipe_Id(
            Long personnelId,
            Long equipeId
    );

    List<EquipePersonnel> findByPersonnelId(Long personnelId);

    Optional<EquipePersonnel> findFirstByPersonnelId(Long personnelId);


    long countByEquipe_ChefEscale_Id(
            Long chefEscaleId
    );

    long countByEquipeId(Long equipeId);

}
