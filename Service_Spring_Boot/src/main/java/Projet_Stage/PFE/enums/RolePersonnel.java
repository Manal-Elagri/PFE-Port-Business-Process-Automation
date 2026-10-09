package Projet_Stage.PFE.enums;

public enum RolePersonnel {
    ADMIN,
    CHEF_EQUIPE,
    CHEF_ESCALE,
    CHEF_SERVICE,
    CHEF_DIVISION,
    POINTEUR,
    OPERATEUR,
    OUVRIER,
    GRUTIER,
    TECHNICIEN,
    Agent_de_contrôle;

    public boolean isChef() {
        return this == ADMIN // Un admin a souvent les droits des chefs
                || this == CHEF_EQUIPE
                || this == CHEF_ESCALE
                || this == CHEF_SERVICE
                || this == CHEF_DIVISION;
    }

    public boolean isEmploye() {
        return !isChef();
    }

}
