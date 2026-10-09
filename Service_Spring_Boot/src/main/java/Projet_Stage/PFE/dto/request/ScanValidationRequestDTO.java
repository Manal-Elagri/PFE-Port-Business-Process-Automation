package Projet_Stage.PFE.dto.request;

public class ScanValidationRequestDTO {

    private Long scanId;
    private String matriculeCorrige;
    private String typeIsoCorrige;

    public ScanValidationRequestDTO() {}

    public Long getScanId() { return scanId; }
    public void setScanId(Long scanId) { this.scanId = scanId; }

    public String getMatriculeCorrige() { return matriculeCorrige; }
    public void setMatriculeCorrige(String matriculeCorrige) { this.matriculeCorrige = matriculeCorrige; }

    public String getTypeIsoCorrige() { return typeIsoCorrige; }
    public void setTypeIsoCorrige(String typeIsoCorrige) { this.typeIsoCorrige = typeIsoCorrige; }
}
