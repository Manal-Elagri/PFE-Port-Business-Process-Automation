import httpx
import json

# REMPLACE PAR TA CLÉ GROQ (celle qui commence par gsk_...)
API_KEY = "******* UN EXEMPLE DE CLÉ GROQ *******" 

def list_groq_models():
    # URL compatible OpenAI pour Groq
    url = "https://api.groq.com/openai/v1/models"
    
    # Pour Groq, la clé passe dans les Headers (Authorization)
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    print(f"Connexion à Groq Cloud pour vérifier ta clé...")
    
    try:
        r = httpx.get(url, headers=headers)
        if r.status_code == 200:
            data = r.json()
            # Dans le format OpenAI, les modèles sont dans la liste 'data'
            models = data.get('data', [])
            
            print("\n✅ CONNEXION RÉUSSIE !")
            print("--- LISTE DES MODÈLES DISPONIBLES SUR GROQ ---")
            
            for m in models:
                # On affiche l'ID du modèle
                print(f"👉 Modèle à utiliser : {m['id']}")
                
        else:
            print(f"\n❌ ERREUR {r.status_code}")
            print(f"Message de Groq : {r.text}")
            
    except Exception as e:
        print(f"\n❌ ERREUR RÉSEAU : {str(e)}")

if __name__ == "__main__":
    list_groq_models()