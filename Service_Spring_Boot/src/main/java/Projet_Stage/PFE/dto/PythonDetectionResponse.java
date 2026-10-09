package Projet_Stage.PFE.dto;

import lombok.Data;

@Data
public class PythonDetectionResponse {

    private String matricule;
    private String type_iso;
    private Double score;
    private boolean is_valid;

}
