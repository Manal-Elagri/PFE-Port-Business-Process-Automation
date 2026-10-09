package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.DocumentAccess;
import Projet_Stage.PFE.enums.StatutSignature;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DocumentAccessRepository extends JpaRepository<DocumentAccess, Long> {

    Optional<DocumentAccess> findByDocumentIdAndToken(Long documentId, String token);

    Optional<DocumentAccess> findByToken(String token);


}
