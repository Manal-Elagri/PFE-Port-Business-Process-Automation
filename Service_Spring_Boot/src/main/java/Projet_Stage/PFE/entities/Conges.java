package Projet_Stage.PFE.entities;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "conges")
public class Conges {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        private LocalDate dateDebut;

        private LocalDate dateFin;

        @Enumerated(EnumType.STRING)
        private Conges.StatutConge statut = StatutConge.EN_ATTENTE;  // EN_ATTENTE, ACCEPTE, REFUSE

        @ManyToOne
        @JoinColumn(name = "personnel_id")
        private Personnel employe;

        @Enumerated(EnumType.STRING)
        private TypeCong type ;


        public enum TypeCong {
            ANNUEL,
            MALADIE,
            SANS_SOLDE
        }

        public enum StatutConge {
            EN_ATTENTE,
            ACCEPTE,
            REFUSE
        }


    public Conges() {
    }

    public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public LocalDate getDateDebut() {
            return dateDebut;
        }

        public void setDateDebut(LocalDate dateDebut) {
            this.dateDebut = dateDebut;
        }

        public LocalDate getDateFin() {
            return dateFin;
        }

        public void setDateFin(LocalDate dateFin) {
            this.dateFin = dateFin;
        }

        public StatutConge getStatut() {
            return statut;
        }

        public void setStatut(StatutConge statut) {
            this.statut = statut;
        }

        public Personnel getEmploye() {
            return employe;
        }

        public void setEmploye(Personnel employe) {
            this.employe = employe;
        }

        public TypeCong getType() {
            return type;
        }

        public void setType(TypeCong type) {
            this.type = type;
        }
    }


