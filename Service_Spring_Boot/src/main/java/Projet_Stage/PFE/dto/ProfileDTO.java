package Projet_Stage.PFE.dto;

import Projet_Stage.PFE.enums.RolePersonnel;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ProfileDTO {
    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private RolePersonnel role;
    private String imageURL;
}