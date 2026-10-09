package Projet_Stage.PFE.repository;


import Projet_Stage.PFE.entities.PlanningJour;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface PlanningJourRepository extends JpaRepository<PlanningJour, Long> {

    // vérifier si un planning existe déjà pour une date donnée
    boolean existsByDate(LocalDate date);

  }
