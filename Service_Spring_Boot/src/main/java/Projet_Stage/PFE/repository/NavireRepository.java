package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.Navire;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface NavireRepository extends JpaRepository<Navire, Long> {


    Optional<Navire> findByNumeroIMO(String numeroIMO);

    boolean existsByNumeroIMO(String numeroIMO);
}
