package Projet_Stage.PFE.controller;


import Projet_Stage.PFE.service.OtpService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/otp")
@RequiredArgsConstructor
public class OtpController {

    private final OtpService otpService;

    // =====================================
    // VALIDER OTP
    // =====================================
    @PostMapping("/validate")
    public ResponseEntity<String> validateOtp(
            @RequestBody Map<String, String> request
    ) {

        otpService.validateOtp(
                Long.valueOf(request.get("documentId")),
                Long.valueOf(request.get("personnelId")),
                request.get("code")
        );

        return ResponseEntity.ok(
                "OTP validé avec succès"
        );
    }


    // =====================================
    // RENVOYER OTP
    // =====================================
    @PostMapping("/resend")
    public ResponseEntity<String> resendOtp(
            @RequestParam Long documentId,
            @RequestParam Long personnelId
    ) {

        otpService.resendOtp(
                documentId,
                personnelId
        );

        return ResponseEntity.ok(
                "Nouveau code OTP envoyé"
        );
    }



}