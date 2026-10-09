package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.entities.Document;
import Projet_Stage.PFE.service.DocumentService;
import Projet_Stage.PFE.service.OperationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/documents")
@RequiredArgsConstructor
public class DocumentController {

    private final DocumentService documentService;
    private final OperationService operationService;

    // =========================
    // CREATE DOCUMENT FOR OPERATION
    // =========================
    @PostMapping("/create/{operationId}")
    public ResponseEntity<Document> createDocument(@PathVariable Long operationId) {

        // récupérer l'opération
        var operation = operationService.findById(operationId);

        // créer document
        Document document = documentService.createDocument(operation);

        return ResponseEntity.ok(document);
    }
}