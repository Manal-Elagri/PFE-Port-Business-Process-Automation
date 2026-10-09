package Projet_Stage.PFE.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public class StartOperationRequest {

    @NotNull(message = "Type opération obligatoire")
    private String type;

    @NotNull(message = "Escale obligatoire")
    private Long escaleId;

    @NotNull(message = "Poste obligatoire")
    private Long posteId;

    @NotNull(message = "Portier obligatoire")
    private Long portierId;

    @NotEmpty(message = "Au moins un engin doit être sélectionné")
    private List<Long> enginIds;

    private Integer nombreConteneurs;

    public StartOperationRequest() {}

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Long getEscaleId() { return escaleId; }
    public void setEscaleId(Long escaleId) { this.escaleId = escaleId; }

    public Long getPosteId() { return posteId; }
    public void setPosteId(Long posteId) { this.posteId = posteId; }

    public Long getPortierId() { return portierId; }
    public void setPortierId(Long portierId) { this.portierId = portierId; }

    public List<Long> getEnginIds() { return enginIds; }
    public void setEnginIds(List<Long> enginIds) { this.enginIds = enginIds; }

    public Integer getNombreConteneurs() { return nombreConteneurs; }
    public void setNombreConteneurs(Integer nombreConteneurs) {
        this.nombreConteneurs = nombreConteneurs;
    }
}