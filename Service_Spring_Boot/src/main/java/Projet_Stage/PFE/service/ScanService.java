package Projet_Stage.PFE.service;

import Projet_Stage.PFE.dto.PythonDetectionResponse;
import Projet_Stage.PFE.dto.request.ScanRequestDTO;
import Projet_Stage.PFE.dto.request.ScanValidationRequestDTO;
import Projet_Stage.PFE.dto.response.ScanResponseDTO;
import Projet_Stage.PFE.entities.*;
import Projet_Stage.PFE.enums.*;
import Projet_Stage.PFE.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.multipart.MultipartFile;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ScanService {

    private final ScanRepository scanRepository;
    private final OperationRepository operationRepository;
    private final ConteneurRepository conteneurRepository;
    private final EmployeService employeService;

    private void validateScanAccess(Operation operation) {

        Equipe equipe =
                employeService.getMyCurrentOperationContext();

        if (!operation.getEquipe()
                .getId()
                .equals(equipe.getId())) {

            throw new RuntimeException(
                    "Cette opération ne vous appartient pas"
            );
        }
    }


    public ScanResponseDTO processImageWithAI(MultipartFile image, Long operationId, String deviceId) {
        // 1. Appel au micro-service Python
        PythonDetectionResponse aiResult = callPythonAIService(image);

        // 2. Préparation de la requête pour ta méthode existante processScan
        ScanRequestDTO request = new ScanRequestDTO();
        request.setMatricule(aiResult.getMatricule());
        request.setTypeIso(aiResult.getType_iso());
        request.setScore(aiResult.getScore());
        request.setOperationId(operationId);
        request.setDeviceId(deviceId);

        // On génère un ID unique pour le mobile ici l'image vient d'être prise
        request.setMobileScanId("AI-" + UUID.randomUUID().toString());
        request.setOfflineMode(false);

        // 3. Utilisation de TA LOGIQUE EXISTANTE
        return this.processScan(request);
    }

    private PythonDetectionResponse callPythonAIService(MultipartFile file) {
        String pythonUrl = "http://localhost:8000/predict"; // URL de ton FastAPI

        RestTemplate restTemplate = new RestTemplate();

        // Préparation du formulaire (Multipart) pour Python
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);

        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("file", file.getResource());

        HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<PythonDetectionResponse> response = restTemplate.postForEntity(
                    pythonUrl, requestEntity, PythonDetectionResponse.class);
            return response.getBody();
        } catch (Exception e) {
            throw new RuntimeException("Erreur de communication avec le service IA : " + e.getMessage());
        }
    }



    // =========================
    // TRAITER SCAN IA
    // =========================
    public ScanResponseDTO processScan(ScanRequestDTO request) {

        Personnel employe =
                employeService.getEmployeConnecte();

        Operation operation =
                operationRepository.findById(request.getOperationId())
                        .orElseThrow(() -> new RuntimeException("Operation not found"));

        validateScanAccess(operation);

        if (operation.getStatut() != StatutOperation.EN_COURS) {
            throw new RuntimeException("Operation non active");
        }

        if (request.getMobileScanId() == null || request.getMobileScanId().isBlank()) {
            throw new RuntimeException("mobileScanId obligatoire");
        }

        if (scanRepository.existsByMobileScanId(request.getMobileScanId())) {
            throw new RuntimeException("Scan déjà synchronisé");
        }
        StatutValidationScan statut;

        boolean matriculeOk = request.getMatricule() != null
                && request.getMatricule().matches("^[A-Z]{4}\\d{7}$")
                && isValidIso6346(request.getMatricule());

        boolean typeIsoOk = request.getTypeIso() != null
                && !request.getTypeIso().equals("NON_DETECTE")
                && request.getTypeIso().length() == 4;

        boolean scoreOk = request.getScore() != null
                && request.getScore() >= 0.85;

        if (matriculeOk && typeIsoOk && scoreOk) {
            statut = StatutValidationScan.VALIDE;
        } else if (request.getScore() != null && request.getScore() >= 0.60) {
            statut = StatutValidationScan.A_VERIFIER;
        } else {
            statut = StatutValidationScan.REJETE;
        }

        Conteneur conteneur = null;

        if (statut == StatutValidationScan.VALIDE) {

            conteneur = conteneurRepository.findByMatricule(request.getMatricule())
                    .orElseGet(() -> conteneurRepository.save(
                            new Conteneur(null,
                                    request.getMatricule(),
                                    request.getTypeIso(),
                                    null)
                    ));

            Integer count = operation.getNombreConteneurs() == null ? 0 : operation.getNombreConteneurs();
            operation.setNombreConteneurs(count + 1);
            operationRepository.save(operation);
        }

        Scan scan = new Scan();

        scan.setMobileScanId(request.getMobileScanId());
        scan.setDeviceId(request.getDeviceId());
        scan.setEmploye(employe);
        scan.setOperation(operation);
        scan.setConteneur(conteneur);

        scan.setDate(LocalDateTime.now());
        scan.setScoreConfiance(request.getScore());
        scan.setStatutValidationScan(statut);

        scan.setSynced(!Boolean.TRUE.equals(request.getOfflineMode()));

        scan.setModeScan(
                Boolean.TRUE.equals(request.getOfflineMode())
                        ? ModeScan.OFFLINE
                        : ModeScan.ONLINE
        );
        String matriculeDetecte = cleanDetectedValue(request.getMatricule());
        String typeIsoDetecte = cleanDetectedValue(request.getTypeIso());

        if (statut == StatutValidationScan.VALIDE
                && matriculeDetecte != null
                && scanRepository.existsByOperationIdAndMatriculeDetecteAndStatutValidationScan(
                request.getOperationId(),
                matriculeDetecte,
                StatutValidationScan.VALIDE
        )) {
            throw new RuntimeException(
                    "Conteneur déjà validé dans cette opération : " + matriculeDetecte
            );
        }

        if (statut == StatutValidationScan.REJETE) {
            scan.setMatriculeDetecte(null);
            scan.setTypeIsoDetecte(null);
        } else {
            scan.setMatriculeDetecte(matriculeDetecte);
            scan.setTypeIsoDetecte(typeIsoDetecte);
        }
        Scan saved = scanRepository.save(scan);

        return mapToDTO(saved);
    }

    private String cleanDetectedValue(String value) {
        if (value == null) return null;

        String cleaned = value.trim().toUpperCase();

        if (cleaned.isBlank() || cleaned.equals("NON_DETECTE")) {
            return null;
        }

        return cleaned;
    }

    private boolean isValidIso6346(String matricule) {
        if (matricule == null || !matricule.matches("^[A-Z]{4}\\d{7}$")) {
            return false;
        }

        String code = matricule.substring(0, 10);
        int checkDigit = Character.getNumericValue(matricule.charAt(10));

        int total = 0;

        for (int i = 0; i < code.length(); i++) {
            char c = code.charAt(i);
            int value;

            if (Character.isDigit(c)) {
                value = Character.getNumericValue(c);
            } else {
                value = letterValue(c);
            }

            total += value * (int) Math.pow(2, i);
        }

        int remainder = total % 11;
        int expected = remainder == 10 ? 0 : remainder;

        return expected == checkDigit;
    }

    private int letterValue(char c) {
        return switch (c) {
            case 'A' -> 10;
            case 'B' -> 12;
            case 'C' -> 13;
            case 'D' -> 14;
            case 'E' -> 15;
            case 'F' -> 16;
            case 'G' -> 17;
            case 'H' -> 18;
            case 'I' -> 19;
            case 'J' -> 20;
            case 'K' -> 21;
            case 'L' -> 23;
            case 'M' -> 24;
            case 'N' -> 25;
            case 'O' -> 26;
            case 'P' -> 27;
            case 'Q' -> 28;
            case 'R' -> 29;
            case 'S' -> 30;
            case 'T' -> 31;
            case 'U' -> 32;
            case 'V' -> 34;
            case 'W' -> 35;
            case 'X' -> 36;
            case 'Y' -> 37;
            case 'Z' -> 38;
            default -> 0;
        };
    }

    // =========================
    // VALIDATION MANUELLE
    // =========================
    public ScanResponseDTO validerScanManuellement(
            ScanValidationRequestDTO request
    ) {

        Scan scan = scanRepository.findById(
                request.getScanId()
        ).orElseThrow(() ->
                new RuntimeException("Scan not found")
        );

        // sécurité équipe
        validateScanAccess(
                scan.getOperation()
        );

        // opération active
        if (scan.getOperation().getStatut()
                != StatutOperation.EN_COURS) {

            throw new RuntimeException(
                    "Validation impossible : opération non active"
            );
        }

        // scan modifiable ?
        if (scan.getStatutValidationScan()
                != StatutValidationScan.A_VERIFIER) {

            throw new RuntimeException(
                    "Scan non modifiable"
            );
        }

        // validation input
        if (request.getMatriculeCorrige() == null
                || request.getMatriculeCorrige().isBlank()) {

            throw new RuntimeException(
                    "Matricule corrigé obligatoire"
            );
        }

        if (request.getTypeIsoCorrige() == null
                || request.getTypeIsoCorrige().isBlank()) {

            throw new RuntimeException(
                    "Type ISO corrigé obligatoire"
            );
        }

        // anti doublon
        String matriculeCorrige = request.getMatriculeCorrige().trim().toUpperCase();
        String typeIsoCorrige = request.getTypeIsoCorrige().trim().toUpperCase();

        boolean alreadyExists =
                scanRepository.existsByOperationIdAndMatriculeDetecteAndStatutValidationScanAndIdNot(
                        scan.getOperation().getId(),
                        matriculeCorrige,
                        StatutValidationScan.VALIDE,
                        scan.getId()
                );

        if (alreadyExists) {
            throw new RuntimeException("Ce conteneur est déjà validé dans cette opération");
        }

        Conteneur conteneur =
                conteneurRepository.findByMatricule(
                        request.getMatriculeCorrige()
                ).orElseGet(() ->
                        conteneurRepository.save(
                                new Conteneur(
                                        null,
                                        request.getMatriculeCorrige(),
                                        request.getTypeIsoCorrige(),
                                        null
                                )
                        )
                );

        // correction
        scan.setMatriculeCorrige(matriculeCorrige);
        scan.setTypeIsoCorrige(typeIsoCorrige);

        scan.setMatriculeDetecte(matriculeCorrige);
        scan.setTypeIsoDetecte(typeIsoCorrige);

        scan.setConteneur(conteneur);
        scan.setStatutValidationScan(StatutValidationScan.VALIDE);

        scanRepository.save(scan);

        // update compteur
        Operation op = scan.getOperation();

        Integer count =
                op.getNombreConteneurs() == null
                        ? 0
                        : op.getNombreConteneurs();

        op.setNombreConteneurs(
                count + 1
        );

        operationRepository.save(op);

        return mapToDTO(scan);
    }

    // =========================
    // MAPPING DTO
    // =========================
    private ScanResponseDTO mapToDTO(Scan scan) {

        return new ScanResponseDTO(
                scan.getId(),
                scan.getMatriculeDetecte(), // IA value
                scan.getTypeIsoDetecte(),
                scan.getScoreConfiance(),
                scan.getStatutValidationScan().name(),
                scan.getDate()
        );
    }


    /// ============== Service de sync =================

    public List<ScanResponseDTO> syncOfflineScans(
            List<ScanRequestDTO> requests
    ) {

        List<ScanResponseDTO> result = new ArrayList<>();

        for (ScanRequestDTO request : requests) {

            if (request == null || request.getMobileScanId() == null) {
                continue;
            }

            try {
                ScanResponseDTO dto = processScan(request);
                result.add(dto);

            } catch (Exception e) {

                // 👉 IMPORTANT PFE: log structuré
                System.err.println(
                        "[SYNC ERROR] device="
                                + request.getDeviceId()
                                + " mobileScanId="
                                + request.getMobileScanId()
                                + " error="
                                + e.getMessage()
                );
            }
        }

        return result;
    }






}