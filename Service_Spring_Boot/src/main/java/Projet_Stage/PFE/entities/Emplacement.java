package Projet_Stage.PFE.entities;

import jakarta.persistence.*;

@Entity
public class Emplacement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String zone;
    private String row;
    private String bay;
    private String tier;

    public Emplacement() {
    }

    public Emplacement(Long id, String zone, String row, String bay, String tier) {
        this.id = id;
        this.zone = zone;
        this.row = row;
        this.bay = bay;
        this.tier = tier;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getZone() {
        return zone;
    }

    public void setZone(String zone) {
        this.zone = zone;
    }

    public String getRow() {
        return row;
    }

    public void setRow(String row) {
        this.row = row;
    }

    public String getBay() {
        return bay;
    }

    public void setBay(String bay) {
        this.bay = bay;
    }

    public String getTier() {
        return tier;
    }

    public void setTier(String tier) {
        this.tier = tier;
    }
}
