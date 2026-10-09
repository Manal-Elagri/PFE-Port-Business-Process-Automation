package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.dto.request.SecureSignatureRequest;
import Projet_Stage.PFE.entities.Document;
import Projet_Stage.PFE.service.SecurityService;
import Projet_Stage.PFE.service.SignatureService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/security")
@RequiredArgsConstructor
public class SecurityController {

    private final SecurityService securityService;
    private final SignatureService signatureService;

    @GetMapping("/documents/{documentId}/pdf")
    public ResponseEntity<byte[]> getDocumentPdf(
            @PathVariable Long documentId,
            @RequestParam String token
    ) {
        return securityService.getDocumentPdf(documentId, token);
    }

    // =====================================
    // ACCES DOCUMENT PAR LIEN SECURISE
    // =====================================
    @GetMapping("/documents/{documentId}/access")
    public ResponseEntity<Document> validateDocumentAccess(
            @PathVariable Long documentId,
            @RequestParam String token
    ) {

        return ResponseEntity.ok(
                securityService.validateAccessWithoutConsume(
                        documentId,
                        token
                )
        );
    }


    @PostMapping("/documents/{documentId}/sign")
    public ResponseEntity<String> signDocumentBySecureLink(
            @PathVariable Long documentId,
            @RequestParam String token,
            @RequestBody SecureSignatureRequest request
    ) {
        Document document = securityService.validateAccessWithoutConsume(
                documentId,
                token
        );

        signatureService.signBySecureLink(
                document,
                request.getOtpCode(),
                request.getSignatureBase64()
        );

        return ResponseEntity.ok("Document signé avec succès");
    }


    @GetMapping(value = "/documents/{documentId}/open", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> openDocumentSignature(
            @PathVariable Long documentId,
            @RequestParam String token
    ) {
        securityService.validateAccessWithoutConsume(documentId, token);

        String appLink = "pfeapp://document-signature?documentId="
                + documentId
                + "&token="
                + token;

        String pdfLink = "http://192.168.8.3:8080/api/security/documents/"
                + documentId
                + "/pdf?token="
                + token;

        String html = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <title>Ouverture du document</title>
                <script>
                    window.location.href = "%s";
                </script>
            </head>
            <body>
                <p>Ouverture de l'application...</p>
                <p>Si l'application ne s'ouvre pas, <a href="%s">cliquez ici pour consulter le PDF</a>.</p>
            </body>
            </html>
            """.formatted(appLink, pdfLink);

        return ResponseEntity.ok(html);
    }


}