package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.Emplacement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmplacementRepository extends JpaRepository<Emplacement, Long> {
}
