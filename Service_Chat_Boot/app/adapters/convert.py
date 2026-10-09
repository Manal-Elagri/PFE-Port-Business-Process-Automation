import base64
import os

def file_to_base64(file_path):
    if not os.path.exists(file_path):
        print(f"Erreur : Le fichier '{file_path}' n'existe pas.")
        return

    # Lecture du fichier en mode binaire
    with open(file_path, "rb") as file:
        binary_data = file.read()
        # Conversion en base64
        base64_encoded = base64.b64encode(binary_data).decode('utf-8')
        
        # On affiche juste les 50 premiers caractères pour vérifier
        print(f"--- Fichier converti : {file_path} ---")
        print(f"Début de la chaîne : {base64_encoded[:50]}...")
        print(f"Taille totale : {len(base64_encoded)} caractères.")
        
        # Sauvegarde dans un fichier texte pour pouvoir copier facilement
        output_file = "base64_output.txt"
        with open(output_file, "w") as out:
            out.write(base64_encoded)
        
        print(f"\n✅ La chaîne complète a été enregistrée dans : {output_file}")
        print("Ouvre ce fichier, copie tout le contenu et colle-le dans le champ 'content' de Swagger.")

# --- METS LE CHEMIN DE TON FICHIER ICI ---
# Exemple : "photo.png" ou "audio.mp3" ou "video.mp4"
mon_fichier = "ton_fichier_ici.mp3" 

file_to_base64(mon_fichier)