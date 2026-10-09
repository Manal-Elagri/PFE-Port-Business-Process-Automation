package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.OtpVerification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OtpVerificationRepository  extends JpaRepository<OtpVerification, Long> {

    Optional<OtpVerification>
    findByDocumentIdAndPersonnelIdAndCode(
            Long documentId,
            Long personnelId,
            String code
    );

    @Modifying
    @Query("""
    UPDATE OtpVerification o
    SET o.used = true
    WHERE o.document.id = :documentId
    AND o.personnel.id = :personnelId
    AND o.used = false
    """)
    void disableOldOtps(Long documentId, Long personnelId);

}
