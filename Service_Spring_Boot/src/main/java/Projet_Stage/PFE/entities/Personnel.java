package Projet_Stage.PFE.entities;

import Projet_Stage.PFE.enums.RolePersonnel;
import jakarta.persistence.*;

@Entity
public class Personnel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nom;
    private String prenom;
    private String imageURL;
    @Enumerated(EnumType.STRING)
    private RolePersonnel role;

    private String telephone;

    // 👇 appartient à une seule équipe
    @ManyToOne
    private Equipe equipe;

    private String email; // login + OTP


    public Personnel() {
    }

    public Personnel(Long id,String imageURL, String nom, String prenom, RolePersonnel role, String telephone, Equipe equipe, String email) {
        this.id = id;
        this.nom = nom;
        this.prenom = prenom;
        this.role = role;
        this.telephone = telephone;
        this.equipe = equipe;
        this.email=email;
        this.imageURL=imageURL;
    }

    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public RolePersonnel getRole() {
        return role;
    }

    public void setRole(RolePersonnel role) {
        this.role = role;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public Equipe getEquipe() {
        return equipe;
    }

    public void setEquipe(Equipe equipe) {
        this.equipe = equipe;
    }


}
