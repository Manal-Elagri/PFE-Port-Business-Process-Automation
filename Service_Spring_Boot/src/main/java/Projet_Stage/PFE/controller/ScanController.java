package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.dto.request.ScanRequestDTO;
import Projet_Stage.PFE.dto.request.ScanValidationRequestDTO;
import Projet_Stage.PFE.dto.response.ScanResponseDTO;
import Projet_Stage.PFE.service.ScanService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/scans")
@RequiredArgsConstructor
public class ScanController {

    private final ScanService scanService;


    // =========================================
    // NOUVEAU : SCAN VIA IMAGE (Appel Micro-service IA)
    // =========================================
    @PostMapping(value = "/process-image", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ScanResponseDTO> processImage(
            @RequestParam("image") org.springframework.web.multipart.MultipartFile image,
            @RequestParam("operationId") Long operationId,
            @RequestParam("deviceId") String deviceId
    ) {
        return ResponseEntity.ok(
                scanService.processImageWithAI(image, operationId, deviceId)
        );
    }


    // =========================================
    // SCAN NORMAL (IA)
    // =========================================
    @PostMapping
    public ResponseEntity<ScanResponseDTO> processScan(
            @RequestBody ScanRequestDTO request
    ) {

        return ResponseEntity.ok(
                scanService.processScan(request)
        );
    }


    // =========================================
    // VALIDATION MANUELLE
    // =========================================
    @PutMapping("/validate")
    public ResponseEntity<ScanResponseDTO> validateScan(
            @RequestBody ScanValidationRequestDTO request
    ) {

        return ResponseEntity.ok(
                scanService.validerScanManuellement(request)
        );
    }


    // =========================================
    // SYNCHRONISATION OFFLINE
    // =========================================
    @PostMapping("/sync")
    public ResponseEntity<List<ScanResponseDTO>> syncOfflineScans(
            @RequestBody List<ScanRequestDTO> requests
    ) {

        return ResponseEntity.ok(
                scanService.syncOfflineScans(requests)
        );
    }

}