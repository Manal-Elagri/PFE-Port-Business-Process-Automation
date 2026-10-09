package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.dto.ArretDTO;
import Projet_Stage.PFE.dto.request.FinishArretRequest;
import Projet_Stage.PFE.dto.request.StartOperationRequest;
import Projet_Stage.PFE.dto.response.OperationResponseDTO;
import Projet_Stage.PFE.service.OperationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/operations")
@RequiredArgsConstructor
public class OperationController {

    private final OperationService operationService;


    // =========================================
   // DEMARRER OPERATION
  // =========================================
    @PostMapping("/start")
    public ResponseEntity<OperationResponseDTO> startOperation(
            @Valid @RequestBody StartOperationRequest request
    ) {
        return ResponseEntity.ok(
                operationService.startOperation(request)
        );
    }

    // =========================================
    // PAUSE OPERATION
    // =========================================
    @PutMapping("/{operationId}/pause")
    public ResponseEntity<String> pauseOperation(
            @PathVariable Long operationId
    ) {

        operationService.pauseOperation(operationId);

        return ResponseEntity.ok(
                "Opération mise en pause avec succès"
        );
    }


    // =========================================
    // REPRENDRE OPERATION
    // =========================================
    @PutMapping("/{operationId}/resume")
    public ResponseEntity<String> resumeOperation(
            @PathVariable Long operationId
    ) {

        operationService.resumeOperation(operationId);

        return ResponseEntity.ok(
                "Opération reprise avec succès"
        );
    }


    // =========================================
    // DECLENCHER ARRET MANUEL
    // =========================================
    @PostMapping("/{operationId}/arret")
    public ResponseEntity<ArretDTO> arretManuel(
            @PathVariable Long operationId
    ) {

        return ResponseEntity.ok(
                operationService.arretManuel(operationId)
        );
    }


    // =========================================
    // TERMINER ARRET
    // =========================================
    @PutMapping("/arrets/{arretId}/finish")
    public ResponseEntity<ArretDTO> terminerArret(
            @PathVariable Long arretId,
            @RequestBody FinishArretRequest request
    ) {
        return ResponseEntity.ok(
                operationService.terminerArret(
                        arretId,
                        request.getCause()
                )
        );
    }


    // =========================================
    // LISTER ARRETS OUVERTS
    // =========================================
    @GetMapping("/{operationId}/arrets")
    public ResponseEntity<List<ArretDTO>> getArretsEnCours(
            @PathVariable Long operationId
    ) {

        return ResponseEntity.ok(
                operationService.getArretsEnCours(
                        operationId
                )
        );
    }


    // =========================================
    // TERMINER OPERATION
    // =========================================
    @PutMapping("/{operationId}/finish")
    public ResponseEntity<String> terminerOperation(
            @PathVariable Long operationId
    ) {

        operationService.terminerOperation(
                operationId
        );

        return ResponseEntity.ok(
                "Opération terminée avec succès"
        );
    }

}