package Projet_Stage.PFE.dto;

import Projet_Stage.PFE.enums.RolePersonnel;
import lombok.Data;

@Data
public class UpdatePersonnelRequest {

    private String nom;

    private String prenom;

    private String telephone;

    private String email;

    private String imageURL;

    private String cin;

    private String password;

    private RolePersonnel rolePersonnel;


}
