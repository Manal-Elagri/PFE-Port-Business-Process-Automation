package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.Signature;
import Projet_Stage.PFE.enums.StatutSignature;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SignatureRepository extends JpaRepository<Signature, Long> {

    List<Signature> findByDocumentId(Long documentId);

    Optional<Signature> findByDocumentIdAndSignataireId(Long documentId, Long signataireId);

    // documents/signatures en attente
    long countBySignataireIdAndStatut(
            Long signataireId,
            StatutSignature statut
    );

    // historique
    List<Signature> findBySignataireIdOrderByDateSignatureDesc(
            Long signataireId
    );


}