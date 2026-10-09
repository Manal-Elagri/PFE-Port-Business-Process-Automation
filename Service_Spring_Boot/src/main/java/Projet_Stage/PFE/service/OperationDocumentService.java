package Projet_Stage.PFE.service;


import Projet_Stage.PFE.dto.*;
import Projet_Stage.PFE.entities.Operation;
import Projet_Stage.PFE.enums.StatutValidationScan;
import Projet_Stage.PFE.repository.OperationRepository;
import Projet_Stage.PFE.repository.ScanRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OperationDocumentService {

    private final ScanRepository scanRepository;
    private final OperationRepository operationRepository;
    private final PdfService pdfService;
    private final SecurityService securityService;

    @Transactional
    public OperationDocumentDTO generateDocument(Long operationId) {

        Operation operation = operationRepository
                .findByIdWithBaseRelations(operationId)
                .orElseThrow(() -> new RuntimeException("Operation not found"));

        operationRepository.findByIdWithArrets(operationId);
        operationRepository.findByIdWithEngins(operationId);

        return mapToDocumentDTO(operation);
    }


    private OperationDocumentDTO mapToDocumentDTO(Operation op) {

        // =========================
        // ARRETS
        // =========================
        List<ArretDTO> arretDTOs = op.getArrets() == null ? List.of() :
                op.getArrets().stream()
                        .map(a -> new ArretDTO(
                                a.getId(),
                                a.getType() != null ? a.getType().name() : null,
                                a.getDateDebut(),
                                a.getDateFin(),
                                a.getCause() != null ? a.getCause().getLibelle() : null
                        ))
                        .toList();

        // =========================
        // ENGINS
        // =========================
        List<EnginDTO> enginDTOs = op.getOperationEngins() == null ? List.of() :
                op.getOperationEngins().stream()
                        .map(oe -> new EnginDTO(
                                oe.getEngin().getId(),
                                oe.getEngin().getType(),
                                oe.getEngin().getCapacite()
                        ))
                        .toList();

        // =========================
        // CONTENEURS
        // =========================
        List<ConteneurDTO> conteneurs = scanRepository
                .findByOperationId(op.getId())
                .stream()
                .filter(s -> s.getStatutValidationScan() == StatutValidationScan.VALIDE)
                .map(s -> new ConteneurDTO(
                        s.getConteneur().getMatricule(),
                        s.getConteneur().getTypeIso()
                ))
                .toList();


        List<ChefSignatureDTO> chefs =
                op.getOperationResponsables()
                        .stream()
                        .map(r -> new ChefSignatureDTO(
                                r.getPersonnel().getNom()
                                        + " "
                                        + r.getPersonnel().getPrenom(),
                                r.getRole().name()
                        ))
                        .toList();
        // =========================
        // RETURN DOCUMENT
        // =========================
        return new OperationDocumentDTO(
                op.getId(),
                op.getType() != null ? op.getType().name() : null,
                op.getStatut() != null ? op.getStatut().name() : null,
                op.getDateDebut(),
                op.getDateFin(),
                op.getNombreConteneurs(),

                // escale
                op.getEscale() != null && op.getEscale().getNavire() != null
                        ? op.getEscale().getNavire().getNom()
                        : null,

                // shift
                op.getShift() != null && op.getShift().getType() != null
                        ? op.getShift().getType().name()
                        : null,

                // poste
                op.getPoste() != null
                        ? String.valueOf(op.getPoste().getNumeroPoste())
                        : null,

                // ✅ portier
                op.getPortier() != null
                        ? op.getPortier().getCode()   // ⚠️ adapte selon ton entité
                        : null,

                // ✅ equipe
                op.getEquipe() != null
                        ? op.getEquipe().getMatriculeEquipe()    // ⚠️ adapte si besoin
                        : null,

                // ✅ conteneurs
                conteneurs,

                // ✅ arrets
                arretDTOs,

                // ✅ engins
                enginDTOs,

                // ✅ chefs
                chefs
        );
    }

    public byte[] generatePdf(Long operationId) {

        // =========================
        // 1️⃣ Récupération operation
        // =========================
        Operation op = operationRepository
                .findByIdWithBaseRelations(operationId)
                .orElseThrow(() -> new RuntimeException("Operation not found"));

        operationRepository.findByIdWithArrets(operationId);
        operationRepository.findByIdWithEngins(operationId);

        // =========================
        // 2️⃣ Construction DTO
        // =========================
        OperationDocumentDTO dto = mapToDocumentDTO(op);

        // =========================
        // 3️⃣ Générer lien sécurisé (IMPORTANT pour QR code + accès)
        // =========================
        String secureLink = securityService.generateSecureLink(op.getId());

        // =========================
        // 4️⃣ Générer PDF
        // =========================
        return pdfService.generateOperationPdf(dto, secureLink);
    }
}
