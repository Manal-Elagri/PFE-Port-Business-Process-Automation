package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.RolePersonnel;
import Projet_Stage.PFE.enums.StatutDemande;
import jakarta.persistence.*;

@Entity
public class DemandeInscription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String codeReference;
    private String imageURL;
    private String nom;

    private String prenom;

    private String telephone;

    private String email;

    private String cin;

    private String password;

    @Enumerated(EnumType.STRING)
    private RolePersonnel roleDemande;

    @Enumerated(EnumType.STRING)
    private StatutDemande statut;

    public DemandeInscription() {
    }


    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getCodeReference() {
        return codeReference;
    }

    public void setCodeReference(String codeReference) {
        this.codeReference = codeReference;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getPrenom() {
        return prenom;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCin() {
        return cin;
    }

    public void setCin(String cin) {
        this.cin = cin;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public RolePersonnel getRoleDemande() {
        return roleDemande;
    }

    public void setRoleDemande(RolePersonnel roleDemande) {
        this.roleDemande = roleDemande;
    }

    public StatutDemande getStatut() {
        return statut;
    }

    public void setStatut(StatutDemande statut) {
        this.statut = statut;
    }
}
