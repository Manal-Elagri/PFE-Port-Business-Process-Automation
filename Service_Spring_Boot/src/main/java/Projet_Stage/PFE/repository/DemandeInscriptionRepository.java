package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.DemandeInscription;
import Projet_Stage.PFE.enums.StatutDemande;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DemandeInscriptionRepository extends JpaRepository<DemandeInscription, Long> {

    Optional<DemandeInscription> findByCodeReference(
            String codeReference
    );

    boolean existsByCin(String cin);

    boolean existsByEmail(String email);

    List<DemandeInscription> findByStatut(StatutDemande statut);


    long countByStatut(
            StatutDemande statut
    );


}
