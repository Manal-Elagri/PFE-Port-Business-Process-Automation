package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.Equipe;
import Projet_Stage.PFE.entities.Personnel;
import Projet_Stage.PFE.enums.RolePersonnel;
import Projet_Stage.PFE.enums.RoleUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PersonnelRepository extends JpaRepository<Personnel, Long> {

    List<Personnel> findByEquipeId(Long equipeId);
    List<Personnel> findByEquipe(Equipe equipe);
    List<Personnel> findByRole(RolePersonnel role);
    List<Personnel> findByRoleIn(List<RoleUser> roles);
    Optional<Personnel> findByTelephone(String telephone);
    long countByRole(
            RolePersonnel role
    );
}
