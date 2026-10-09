package Projet_Stage.PFE.auth;

import Projet_Stage.PFE.enums.RoleUser;

public class AuthResponse {

    private String token;
    private RoleUser role;
    private String nom;

    public AuthResponse(String token, RoleUser role, String nom) {
        this.token = token;
        this.role = role;
        this.nom = nom;
    }

    public String getToken() {
        return token;
    }

    public RoleUser getRole() {
        return role;
    }

    public String getNom() {
        return nom;
    }

}
