package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.Escale;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface EscaleRepository extends JpaRepository<Escale, Long> {

    Optional<Escale> findByNumeroEscale(String numeroEscale);

    List<Escale> findByNavireId(Long navireId);

    List<Escale> findByDateArriveeBetween(LocalDate start, LocalDate end);
}
