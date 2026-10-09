# Microservice IA (FastAPI) — OpenAI + OpenRouter

Microservice REST **prêt production** en Python (FastAPI) avec :
- **Strategy pattern** pour switch dynamique entre providers
- **Adapter pattern** pour OpenAI et OpenRouter
- **Support multimodal** (texte / image / audio) via OpenAI (par défaut)
- **Input JSON uniquement** + **output interne JSON uniquement** (inclut `formatted_response` pour affichage frontend)
- **Gestion tokens avancée** (usage provider si dispo, sinon fallback tokenizer)
- Sécurité **API key** + **rate limiting** + middleware de logging + erreurs centralisées

## Arborescence

```
.
├─ app/
│  ├─ main.py
│  ├─ config/
│  ├─ routers/
│  ├─ services/
│  ├─ providers/
│  ├─ adapters/
│  ├─ schemas/
│  ├─ middleware/
│  └─ utils/
├─ requirements.txt
├─ Dockerfile
├─ docker-compose.yml
├─ static/           # Interface web
│  ├─ index.html
│  ├─ css/style.css
│  └─ js/app.js
├─ .env.example
└─ .gitignore
```

## Interface web

Une interface intuitive est servie à la racine :

- **URL** : `http://localhost:8000/` (après démarrage du serveur)
- **Clé API** : saisir la même valeur que `SERVICE_API_KEY` (.env) dans le champ « Clé API »
- **Fournisseur** : OpenAI (par défaut) ou OpenRouter
- **OpenRouter** : choix du modèle (liste chargée depuis l’API, filtre modèles gratuits)
- **Type d’entrée** : Texte, Image ou Audio (fichier converti en base64)
- **Réponse** : affichage lisible (pas de JSON brut) + statistiques (tokens, temps, coût estimé)

## Configuration (.env)

1) Copier `.env.example` → `.env`
2) Remplir :
- `SERVICE_API_KEY`
- `OPENAI_API_KEY` (pour OpenAI)
- `OPENROUTER_API_KEY` (pour OpenRouter + /models)

## Lancer en local (dev)

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

> Sur Windows, si `uvicorn` n'est pas reconnu, utilisez toujours `python -m uvicorn` (avec le venv activé), ou :
> `.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`

## Lancer en Docker

```bash
docker compose up --build
```

## Bot WhatsApp (intermédiaire +212 689 461 643)

**Ce que vous voulez (et ce que fait l’app) :**

1. Vous **scannez un QR** → WhatsApp ouvre le contact **0689461643 / +212 689 461 643** (comme `wa.me`).
2. Vous **écrivez depuis votre téléphone** à ce contact (vous ne connectez pas votre WhatsApp à l’application).
3. Le **numéro +212 689 461 643** reçoit le message sur le serveur (**Neonize**, liaison admin une fois).
4. L’**IA** (Groq/Ollama) génère la réponse → renvoyée **dans WhatsApp**.

### Configuration Neonize (admin, une fois)

1. `.env` : `WHATSAPP_DRIVER=neonize`, `GROQ_API_KEY=...` (ou `WHATSAPP_AI_PROVIDER=ollama`).
2. Démarrer l’API : `python -m uvicorn app.main:app --host 127.0.0.1 --port 8000`
3. Dashboard → **Mon Bot WhatsApp** → ouvrir **Configuration serveur (admin)**.
4. **Démarrer la connexion Neonize** → **Afficher le QR serveur**.
5. Sur le téléphone **+212 689 461 643** : WhatsApp → **Appareils connectés** → scanner ce QR.
6. Les utilisateurs scannent uniquement le **QR contact** (wa.me) affiché au-dessus.

Option payante alternative : `WHATSAPP_DRIVER=cloud` + API Meta (webhook `/v1/whatsapp/meta/webhook`).

Règles IA : `config/whatsapp_rules.json`. Historique : `data/whatsapp_history.db`.

## Endpoints

- `GET /healthz` (sans auth)
- `POST /v1/generate` (auth `X-API-Key`)
- `GET /v1/openrouter/models?free_only=true` (auth `X-API-Key`)
- `GET /metrics` (auth `X-API-Key`)
- `GET /v1/whatsapp/status`, `GET /v1/whatsapp/qr` (QR contact wa.me)
- `GET/POST /v1/whatsapp/meta/webhook` (webhook Meta, sans clé API dashboard)
- `GET /v1/whatsapp/history`, `GET/PUT /v1/whatsapp/rules`, `POST /v1/whatsapp/webhook` (simulation)

## Exemple — génération texte (OpenAI par défaut)

```json
{
  "input_type": "text",
  "content": "Explique Clean Architecture en 5 lignes.",
  "temperature": 0.7,
  "max_tokens": 300
}
```

## Exemple — génération image (OpenAI)

`content` doit être une chaîne base64 (sans préfixe `data:`). Optionnel : `content_mime_type`.

```json
{
  "input_type": "image",
  "content_mime_type": "image/png",
  "content": "<BASE64_IMAGE>",
  "temperature": 0.2,
  "max_tokens": 300
}
```

## Exemple — génération audio (OpenAI)

`content` doit être une chaîne base64. Optionnel : `audio_format`.

```json
{
  "input_type": "audio",
  "audio_format": "wav",
  "content": "<BASE64_AUDIO>",
  "temperature": 0.2,
  "max_tokens": 300
}
```

## Exemple — OpenRouter (modèle obligatoire)

1) Lister les modèles gratuits :
`GET /v1/openrouter/models?free_only=true`

2) Générer :

```json
{
  "provider": "openrouter",
  "model": "openrouter/<MODEL_ID>",
  "input_type": "text",
  "content": "Donne-moi un plan de projet en 10 points.",
  "temperature": 0.7,
  "max_tokens": 500
}
```

## Affichage frontend (pas de JSON brut)

Utiliser :
- `formatted_response` pour afficher la réponse
- `provider`, `model`, `usage.*`, `response_time_ms` pour les stats

