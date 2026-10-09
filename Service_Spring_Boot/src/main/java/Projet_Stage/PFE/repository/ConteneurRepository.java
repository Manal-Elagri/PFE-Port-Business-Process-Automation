package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.Conteneur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ConteneurRepository extends JpaRepository<Conteneur, Long> {


    Optional<Conteneur> findByMatricule(String matricule);
}
