package Projet_Stage.PFE.service;

import Projet_Stage.PFE.entities.DemandeInscription;
import Projet_Stage.PFE.enums.RolePersonnel;
import Projet_Stage.PFE.enums.StatutDemande;
import Projet_Stage.PFE.repository.DemandeInscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DemandeInscriptionService {

    private final DemandeInscriptionRepository demandeRepository;
    private final PasswordEncoder passwordEncoder;


    // =========================================
    // GENERER CODE REFERENCE
    // =========================================
    private String generateReferenceCode() {

        return "REQ-"
                + LocalDate.now()
                + "-"
                + java.util.UUID.randomUUID()
                .toString()
                .substring(0, 8);
    }


    // =========================================
    // 1. CREER UNE DEMANDE
    // =========================================
    public DemandeInscription createRequest(
            String imageURL,
            String nom,
            String prenom,
            String telephone,
            String email,
            String cin,
            String password,
            RolePersonnel role
    ) {

        if (demandeRepository.existsByCin(cin)) {
            throw new RuntimeException(
                    "CIN déjà utilisé"
            );
        }

        if (email != null && !email.isBlank()
                && demandeRepository.existsByEmail(email)) {
            throw new RuntimeException("Email déjà utilisé");
        }

        DemandeInscription demande =
                new DemandeInscription();

        demande.setCodeReference(
                generateReferenceCode()
        );

        demande.setImageURL(
                imageURL
        );

        demande.setNom(
                nom
        );

        demande.setPrenom(
                prenom
        );

        demande.setTelephone(
                telephone
        );

        demande.setEmail(
                email
        );

        demande.setCin(
                cin
        );

        demande.setPassword(
                passwordEncoder.encode(password)
        );

        demande.setRoleDemande(
                role
        );

        demande.setStatut(
                StatutDemande.EN_ATTENTE
        );

        return demandeRepository.save(
                demande
        );
    }


    // =========================================
    // 2. RECHERCHER PAR CODE REFERENCE
    // =========================================
    public DemandeInscription getByReference(
            String codeReference
    ) {

        return demandeRepository
                .findByCodeReference(codeReference)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Demande introuvable"
                        ));
    }


    // =========================================
    // 4. ANNULER DEMANDE
    // =========================================
    public void cancelRequest(
            Long demandeId
    ) {

        DemandeInscription demande =
                demandeRepository.findById(demandeId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Demande introuvable"
                                ));

        if (demande.getStatut()
                != StatutDemande.EN_ATTENTE) {

            throw new RuntimeException(
                    "Impossible d'annuler une demande déjà traitée"
            );
        }

        demandeRepository.delete(
                demande
        );
    }


}