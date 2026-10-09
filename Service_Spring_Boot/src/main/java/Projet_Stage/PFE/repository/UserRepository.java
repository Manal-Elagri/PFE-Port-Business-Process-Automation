package Projet_Stage.PFE.repository;

import Projet_Stage.PFE.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    Optional<User> findByCin(String cin);

    boolean existsByEmail(String email);

    Optional<User> findByCinOrPersonnelEmail(
            String cin,
            String email
    );

    Optional<User> findByPersonnelId(
            Long personnelId);

    Optional<User> findByResetToken(String resetToken);

}
