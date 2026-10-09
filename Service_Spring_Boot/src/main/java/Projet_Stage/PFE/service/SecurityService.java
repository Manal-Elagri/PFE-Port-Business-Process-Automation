package Projet_Stage.PFE.service;

import Projet_Stage.PFE.entities.Document;
import Projet_Stage.PFE.entities.DocumentAccess;
import Projet_Stage.PFE.repository.DocumentAccessRepository;
import Projet_Stage.PFE.repository.DocumentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.UUID;
import java.io.ByteArrayOutputStream;

@Service
@RequiredArgsConstructor
public class SecurityService {

    private final DocumentAccessRepository documentAccessRepository;
    private final DocumentRepository documentRepository;

    // =========================
    // LIEN SECURISE
    // =========================
    public String generateSecureLink(Long documentId) {

        Document doc = documentRepository.findById(documentId)
                .orElseThrow(() -> new RuntimeException("Document introuvable"));

        String token = UUID.randomUUID().toString();

        DocumentAccess access = new DocumentAccess();
        access.setDocument(doc);
        access.setToken(token);
        access.setExpiration(LocalDateTime.now().plusHours(24));
        access.setUtilise(false);

        documentAccessRepository.save(access);

        return "http://192.168.8.3:8080/api/security/documents/"
                + documentId
                + "/open?token="
                + token;
    }

    // =========================
    // VALIDATION ACCES
    // =========================
    public Document validateAccessWithoutConsume(Long documentId, String token) {

        DocumentAccess access = documentAccessRepository
                .findByDocumentIdAndToken(documentId, token)
                .orElseThrow(() -> new RuntimeException("Lien invalide"));

        if (Boolean.TRUE.equals(access.getUtilise())) {
            throw new RuntimeException("Lien déjà utilisé");
        }

        if (access.getExpiration().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Lien expiré");
        }

        //access.setUtilise(true);
        //documentAccessRepository.save(access);

        return access.getDocument();
    }

    // =========================
    // QR CODE
    // =========================
    public byte[] generateQrCode(String text) {

        try {
            com.google.zxing.qrcode.QRCodeWriter writer =
                    new com.google.zxing.qrcode.QRCodeWriter();

            com.google.zxing.common.BitMatrix matrix =
                    writer.encode(text,
                            com.google.zxing.BarcodeFormat.QR_CODE,
                            200, 200);

            ByteArrayOutputStream out = new ByteArrayOutputStream();

            com.google.zxing.client.j2se.MatrixToImageWriter
                    .writeToStream(matrix, "PNG", out);

            return out.toByteArray();

        } catch (Exception e) {
            throw new RuntimeException("Erreur QR Code", e);
        }
    }


    public ResponseEntity<byte[]> getDocumentPdf(Long documentId, String token) {

        Document document = validateAccessWithoutConsume(documentId, token);

        if (document.getPdfPath() == null) {
            throw new RuntimeException("PDF introuvable");
        }

        try {
            Path path = Paths.get(document.getPdfPath());
            byte[] pdfBytes = Files.readAllBytes(path);

            return ResponseEntity.ok()
                    .header("Content-Disposition", "inline; filename=document_" + documentId + ".pdf")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(pdfBytes);

        } catch (IOException e) {
            throw new RuntimeException("Erreur lecture PDF", e);
        }
    }




}