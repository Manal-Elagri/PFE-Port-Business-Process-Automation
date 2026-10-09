package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.dto.request.SignatureRequestDTO;
import Projet_Stage.PFE.entities.Signature;
import Projet_Stage.PFE.service.SignatureService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/signatures")
@RequiredArgsConstructor
public class SignatureController {

    private final SignatureService signatureService;


    // =========================================
    // SIGNER DOCUMENT
    // =========================================
    @PostMapping("/sign")
    public ResponseEntity<String> signDocument(
            @RequestBody SignatureRequestDTO request
    ) {

        signatureService.signer(
                request.getDocumentId(),
                request.getPersonnelId(),
                request.getOtpCode(),
                request.getSignatureBase64()
        );

        return ResponseEntity.ok(
                "Document signé avec succès"
        );
    }

    // =========================================
    // SIGNATURES D'UN DOCUMENT
    // =========================================
    @GetMapping("/document/{documentId}")
    public ResponseEntity<List<Signature>> getDocumentSignatures(
            @PathVariable Long documentId
    ) {

        return ResponseEntity.ok(
                signatureService.getDocumentSignatures(
                        documentId
                )
        );
    }

}