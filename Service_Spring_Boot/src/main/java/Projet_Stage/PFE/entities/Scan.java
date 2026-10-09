package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.ModeScan;
import Projet_Stage.PFE.enums.StatutValidationScan;
import jakarta.persistence.*;
import java.time.LocalDateTime;


@Entity
@Table(
        uniqueConstraints = {
                @UniqueConstraint(
                        columnNames = {
                                "operation_id",
                                "matriculeDetecte"
                        }
                )
        }
)
public class Scan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    // IDENTIFIANT MOBILE UNIQUE
    // Evite doublons lors sync offline
    @Column(unique = true, nullable = false)
    private String mobileScanId;

    // 📅 Date du scan
    @Column(nullable = false)
    private LocalDateTime date;

    // 🧠 Score IA
    @Column(nullable = false)
    private Double scoreConfiance;

    // 📊 Statut du scan (VALIDE / A_VERIFIER / REJETE)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutValidationScan statutValidationScan;

    // 🔁 Synchronisation (mobile / backend)
    @Column(nullable = false)
    private Boolean synced = false;

    // MODE D'ORIGINE
    // OFFLINE / ONLINE
    // =========================
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ModeScan modeScan;

    // APPAREIL SOURCE
    // ex : Samsung A54 / Tablet 01
    // =========================
    @Column(nullable = false)
    private String deviceId;


    // 🚢 Conteneur final (UNIQUEMENT si VALIDE)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conteneur_id")
    private Conteneur conteneur;

    // ⚙️ Operation liée
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "operation_id")
    private Operation operation;

    // EMPLOYÉ QUI A SCANNÉ
    // audit + sécurité
    // =========================
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "personnel_id")
    private Personnel employe;

    // 🤖 Données détectées par l’IA
    @Column(nullable = false)
    private String matriculeDetecte;
    @Column(nullable = false)
    private String typeIsoDetecte;

    // ✏️ Données corrigées par l’opérateur (si A_VERIFIER)
    private String matriculeCorrige;
    private String typeIsoCorrige;

    public Scan() {
    }

    // =========================
    // GETTERS / SETTERS
    // =========================


    public Personnel getEmploye() {
        return employe;
    }

    public void setEmploye(Personnel employe) {
        this.employe = employe;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getMobileScanId() {
        return mobileScanId;
    }

    public void setMobileScanId(String mobileScanId) {
        this.mobileScanId = mobileScanId;
    }

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
    }

    public Double getScoreConfiance() {
        return scoreConfiance;
    }

    public void setScoreConfiance(Double scoreConfiance) {
        this.scoreConfiance = scoreConfiance;
    }

    public StatutValidationScan getStatutValidationScan() {
        return statutValidationScan;
    }

    public void setStatutValidationScan(StatutValidationScan statutValidationScan) {
        this.statutValidationScan = statutValidationScan;
    }

    public Boolean getSynced() {
        return synced;
    }

    public void setSynced(Boolean synced) {
        this.synced = synced;
    }

    public ModeScan getModeScan() {
        return modeScan;
    }

    public void setModeScan(ModeScan modeScan) {
        this.modeScan = modeScan;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public Conteneur getConteneur() {
        return conteneur;
    }

    public void setConteneur(Conteneur conteneur) {
        this.conteneur = conteneur;
    }

    public Operation getOperation() {
        return operation;
    }

    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public String getMatriculeDetecte() {
        return matriculeDetecte;
    }

    public void setMatriculeDetecte(String matriculeDetecte) {
        this.matriculeDetecte = matriculeDetecte;
    }

    public String getTypeIsoDetecte() {
        return typeIsoDetecte;
    }

    public void setTypeIsoDetecte(String typeIsoDetecte) {
        this.typeIsoDetecte = typeIsoDetecte;
    }

    public String getMatriculeCorrige() {
        return matriculeCorrige;
    }

    public void setMatriculeCorrige(String matriculeCorrige) {
        this.matriculeCorrige = matriculeCorrige;
    }

    public String getTypeIsoCorrige() {
        return typeIsoCorrige;
    }

    public void setTypeIsoCorrige(String typeIsoCorrige) {
        this.typeIsoCorrige = typeIsoCorrige;
    }
}