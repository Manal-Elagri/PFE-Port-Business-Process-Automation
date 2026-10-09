package Projet_Stage.PFE.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
@Entity
public class Poste {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer numeroPoste;
    private String localisation;
    private Double latitude;
    private Double longitude;
    public Poste() {
    }

    public Poste(Long id, Integer numeroPoste, String localisation, Double latitude, Double longitude) {
        this.id = id;
        this.numeroPoste = numeroPoste;
        this.localisation = localisation;
        this.latitude = latitude;
        this.longitude = longitude;
    }


    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getNumeroPoste() {
        return numeroPoste;
    }

    public void setNumeroPoste(Integer numeroPoste) {
        this.numeroPoste = numeroPoste;
    }

    public String getLocalisation() {
        return localisation;
    }

    public void setLocalisation(String localisation) {
        this.localisation = localisation;
    }
}
