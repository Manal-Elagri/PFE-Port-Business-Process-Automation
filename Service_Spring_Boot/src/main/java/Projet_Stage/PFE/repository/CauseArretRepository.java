package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.CauseArret;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CauseArretRepository extends JpaRepository<CauseArret, Long> {
    Optional<CauseArret> findByLibelleIgnoreCase(String libelle);

}
