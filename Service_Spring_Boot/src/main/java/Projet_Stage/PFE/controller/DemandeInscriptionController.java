package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.entities.DemandeInscription;
import Projet_Stage.PFE.enums.RolePersonnel;
import Projet_Stage.PFE.service.DemandeInscriptionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.nio.file.*;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
@RestController
@RequestMapping("/api/demandes-inscription")
@RequiredArgsConstructor
public class DemandeInscriptionController {

    private final DemandeInscriptionService demandeService;


    // =========================================
    // 1. CREER UNE DEMANDE
    // =========================================
    @PostMapping
    public DemandeInscription createRequest(

            @RequestParam String imageURL,
            @RequestParam String nom,
            @RequestParam String prenom,
            @RequestParam String telephone,

            // peut être vide si non obligatoire
            @RequestParam(required = false) String email,

            @RequestParam String cin,
            @RequestParam String password,
            @RequestParam RolePersonnel role

    ) {

        return demandeService.createRequest(
                imageURL,
                nom,
                prenom,
                telephone,
                email,
                cin,
                password,
                role
        );
    }


    // =========================================
    // 2. SUIVI PAR CODE REFERENCE
    // =========================================
    @GetMapping("/reference/{codeReference}")
    public DemandeInscription getByReference(
            @PathVariable String codeReference
    ) {

        return demandeService.getByReference(
                codeReference
        );
    }


    // =========================================
    // 3. ANNULER UNE DEMANDE
    // =========================================
    @DeleteMapping("/{demandeId}")
    public void cancelRequest(
            @PathVariable Long demandeId
    ) {

        demandeService.cancelRequest(
                demandeId
        );
    }



    @Value("${app.upload.dir:uploads}")
    private String uploadDir;


    @PostMapping("/upload")
    public ResponseEntity<Map<String, String>> uploadImage(
            @RequestParam("file") MultipartFile file
    ) {

        try {

            String originalName =
                    StringUtils.cleanPath(
                            file.getOriginalFilename()
                    );

            String uniqueName =
                    UUID.randomUUID()
                            + "_"
                            + originalName;

            String folder =
                    Paths.get(
                            uploadDir,
                            "ProjetPFE"
                    ).toString();

            Files.createDirectories(
                    Paths.get(folder)
            );

            Path target =
                    Paths.get(
                            folder,
                            uniqueName
                    );

            Files.copy(
                    file.getInputStream(),
                    target,
                    StandardCopyOption.REPLACE_EXISTING
            );

            String imageUrl =
                    ServletUriComponentsBuilder
                            .fromCurrentContextPath()
                            .path("/uploads/ProjetPFE/")
                            .path(uniqueName)
                            .toUriString();

            Map<String, String> response =
                    new HashMap<>();

            response.put(
                    "imageUrl",
                    imageUrl
            );

            return ResponseEntity.ok(
                    response
            );

        } catch (Exception e) {

            return ResponseEntity
                    .internalServerError()
                    .build();
        }
    }

}