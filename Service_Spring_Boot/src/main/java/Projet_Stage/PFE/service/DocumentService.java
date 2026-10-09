package Projet_Stage.PFE.service;

import Projet_Stage.PFE.entities.Document;
import Projet_Stage.PFE.entities.Operation;
import Projet_Stage.PFE.enums.StatutDocument;
import Projet_Stage.PFE.repository.DocumentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class DocumentService {

    private final DocumentRepository documentRepository;


    public Document createDocument(Operation operation) {

        Document doc = new Document();
        doc.setOperation(operation);
        doc.setDateGeneration(LocalDateTime.now());
        doc.setStatut(StatutDocument.EN_ATTENTE);

        return documentRepository.save(doc);
    }
}
