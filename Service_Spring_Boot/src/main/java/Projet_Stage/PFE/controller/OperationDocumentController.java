package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.dto.OperationDocumentDTO;
import Projet_Stage.PFE.service.OperationDocumentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/operation-documents")
@RequiredArgsConstructor
public class OperationDocumentController {

    private final OperationDocumentService operationDocumentService;


    // =====================================================
    // Voir les données du document
    // =====================================================
    @GetMapping("/{operationId}")
    public ResponseEntity<OperationDocumentDTO> getDocument(
            @PathVariable Long operationId
    ) {

        return ResponseEntity.ok(
                operationDocumentService.generateDocument(operationId)
        );
    }


    // =====================================================
    // Télécharger PDF
    // =====================================================
    @GetMapping("/{operationId}/pdf")
    public ResponseEntity<byte[]> generatePdf(
            @PathVariable Long operationId
    ) {

        byte[] pdf =
                operationDocumentService.generatePdf(operationId);

        return ResponseEntity.ok()
                .header(
                        HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=operation_" + operationId + ".pdf"
                )
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }

}