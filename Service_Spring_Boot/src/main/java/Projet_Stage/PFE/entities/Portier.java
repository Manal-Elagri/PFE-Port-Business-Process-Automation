package Projet_Stage.PFE.entities;

import jakarta.persistence.*;

@Entity
public class Portier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String code;
    private Integer nombreCameras;

    public Portier() {
    }

    public Portier(Long id, String code, Integer nombreCameras) {
        this.id = id;
        this.code = code;
        this.nombreCameras = nombreCameras;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public Integer getNombreCameras() {
        return nombreCameras;
    }

    public void setNombreCameras(Integer nombreCameras) {
        this.nombreCameras = nombreCameras;
    }
}
