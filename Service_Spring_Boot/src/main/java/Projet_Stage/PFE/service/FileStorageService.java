package Projet_Stage.PFE.service;

import org.springframework.stereotype.Service;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import java.util.Base64;

@Service
public class FileStorageService {

    public String save(byte[] file, String filename) {
        try {
            Path folder = Paths.get("uploads");

            if (!Files.exists(folder)) {
                Files.createDirectories(folder); // ✅ créer dossier
            }

            Path path = folder.resolve(filename);

            Files.write(path, file); // ✅ maintenant ça marche

            return path.toString();

        } catch (IOException e) {
            throw new RuntimeException("Erreur sauvegarde fichier", e);
        }
    }

    public String saveBase64Signature(
            String base64Signature,
            String filename
    ) {

        try {

            // retirer header data:image/png;base64,
            String cleanBase64 =
                    base64Signature.split(",")[1];

            byte[] imageBytes =
                    Base64.getDecoder()
                            .decode(cleanBase64);

            Path folder =
                    Paths.get("uploads/signatures");

            if (!Files.exists(folder)) {
                Files.createDirectories(folder);
            }

            Path filePath =
                    folder.resolve(filename);

            Files.write(
                    filePath,
                    imageBytes
            );

            return filePath.toString();

        } catch (Exception e) {
            throw new RuntimeException(
                    "Erreur sauvegarde signature",
                    e
            );
        }
    }
}
