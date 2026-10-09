package Projet_Stage.PFE.entities;


import jakarta.persistence.*;

import java.time.LocalDate;
import java.util.List;

@Entity
public class PlanningJour {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private LocalDate date;

    // Un planning journalier contient plusieurs shifts
    @OneToMany(mappedBy = "planningJour", cascade = CascadeType.ALL)
    private List<Shift> shifts;

    public PlanningJour() {
    }

    public PlanningJour(Long id, LocalDate date, List<Shift> shifts) {
        this.id = id;
        this.date = date;
        this.shifts = shifts;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public List<Shift> getShifts() {
        return shifts;
    }

    public void setShifts(List<Shift> shifts) {
        this.shifts = shifts;
    }
}
