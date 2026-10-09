package Projet_Stage.PFE.dto.request;

public class SignatureRequestDTO {

    private Long documentId;

    private String otpCode;

    private Long personnelId;

    private String signatureBase64;

    public SignatureRequestDTO() {
    }

    public Long getPersonnelId() {
        return personnelId;
    }

    public void setPersonnelId(Long personnelId) {
        this.personnelId = personnelId;
    }

    public Long getDocumentId() {
        return documentId;
    }

    public void setDocumentId(Long documentId) {
        this.documentId = documentId;
    }

    public String getOtpCode() {
        return otpCode;
    }

    public void setOtpCode(String otpCode) {
        this.otpCode = otpCode;
    }

    public String getSignatureBase64() {
        return signatureBase64;
    }

    public void setSignatureBase64(String signatureBase64) {
        this.signatureBase64 = signatureBase64;
    }
}
