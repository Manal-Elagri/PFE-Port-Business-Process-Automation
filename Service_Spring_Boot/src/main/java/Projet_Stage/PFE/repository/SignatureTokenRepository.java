package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.SignatureToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SignatureTokenRepository extends JpaRepository<SignatureToken, Long> {

    Optional<SignatureToken> findByToken(String token);
}
