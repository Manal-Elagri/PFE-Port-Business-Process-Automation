package Projet_Stage.PFE.controller;

import Projet_Stage.PFE.repository.PersonnelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/internal/personnel")
@RequiredArgsConstructor
public class InternalPersonnelController {

    private final PersonnelRepository personnelRepository;

    @GetMapping("/by-phone/{phone}")
    public ResponseEntity<?> getUserIdByPhone(@PathVariable String phone) {

        // --- LOGIQUE DE NETTOYAGE ICI ---
        // On enlève le "+" s'il existe

        // Conversion format international (2126...) vers local (06...)
        // Si le numéro commence par 2126 ou 2127, on remplace 212 par 0
        String cleanPhone = phone
                .replace("+", "")
                .replace(" ", "")
                .replace("@lid", "")
                .replaceAll("[^0-9]", "");
// 🔥 CAS IMPORTANT : si numéro est trop long → garder les 10 derniers chiffres
        if (cleanPhone.startsWith("212")) {
            cleanPhone = "0" + cleanPhone.substring(3);
        }

        System.out.println("RAW = " + phone);
        System.out.println("CLEAN = " + cleanPhone);
        // Log pour vérifier dans la console Java si le nettoyage fonctionne
        System.out.println("DEBUG: WhatsApp phone [" + phone + "] converti en [" + cleanPhone + "]");

        return personnelRepository.findByTelephone(cleanPhone)
                .map(p -> ResponseEntity.ok(Map.of(
                        "id", p.getId(),
                        "nom", p.getNom()
                )))
                .orElse(ResponseEntity.notFound().build());
    }

}