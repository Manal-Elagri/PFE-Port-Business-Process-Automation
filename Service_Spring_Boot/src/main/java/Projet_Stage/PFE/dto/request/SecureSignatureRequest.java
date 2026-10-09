package Projet_Stage.PFE.dto.request;

public class SecureSignatureRequest {

    private String otpCode;
    private String signatureBase64;

    public SecureSignatureRequest() {
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