package Projet_Stage.PFE.dto.request;

public class ScanRequestDTO {
    private Long operationId;

    private String mobileScanId;

    private String deviceId;

    private String matricule;

    private String typeIso;

    private Double score;

    private Boolean offlineMode;

    public ScanRequestDTO() {
    }


    public Long getOperationId() {
        return operationId;
    }

    public void setOperationId(Long operationId) {
        this.operationId = operationId;
    }

    public String getMobileScanId() {
        return mobileScanId;
    }

    public void setMobileScanId(String mobileScanId) {
        this.mobileScanId = mobileScanId;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public String getMatricule() {
        return matricule;
    }

    public void setMatricule(String matricule) {
        this.matricule = matricule;
    }

    public String getTypeIso() {
        return typeIso;
    }

    public void setTypeIso(String typeIso) {
        this.typeIso = typeIso;
    }

    public Double getScore() {
        return score;
    }

    public void setScore(Double score) {
        this.score = score;
    }

    public Boolean getOfflineMode() {
        return offlineMode;
    }

    public void setOfflineMode(Boolean offlineMode) {
        this.offlineMode = offlineMode;
    }
}
