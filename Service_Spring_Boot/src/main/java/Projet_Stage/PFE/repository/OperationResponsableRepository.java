package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.OperationResponsable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OperationResponsableRepository extends JpaRepository<OperationResponsable, Long> {

    Optional<OperationResponsable> findFirstByOperationIdOrderByOrdreSignatureAsc(Long operationId);
    List<OperationResponsable> findByOperationIdOrderByOrdreSignature(Long operationId);
}
