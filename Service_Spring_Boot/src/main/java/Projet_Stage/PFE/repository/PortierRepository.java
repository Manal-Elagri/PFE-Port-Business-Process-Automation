package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.Portier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PortierRepository extends JpaRepository<Portier, Long> {
}
