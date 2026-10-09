from __future__ import annotations
from typing import Any
import httpx
from app.config.settings import get_settings
from app.schemas.ai import GenerationRequest
from app.utils.exceptions import ProviderRequestError

class GeminiAdapter:
    def __init__(self) -> None:
        self._settings = get_settings()
        self.api_key = str(self._settings.gemini_api_key or "").strip()

    async def generate_content(self, *, model: str, req: GenerationRequest) -> dict[str, Any]:
        # 1. Configuration du modèle (On reste sur le 2.5 flash qui marche chez toi)
        selected_model = "gemini-2.5-flash"
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{selected_model}:generateContent"
        params = {"key": self.api_key}

        # 2. Nettoyage du Base64
        b64_data = req.content
        if "," in b64_data:
            b64_data = b64_data.split(",")[1]

        # 3. Construction du message Multimodal (Texte + Fichier)
        parts = []
        
        # On détermine le texte à envoyer :
        # Si on a un 'user_prompt' (texte sous l'image), on le prend.
        # Sinon, si c'est du texte seul, on prend 'content'.
        # Sinon, on met une phrase par défaut.
        if req.user_prompt:
            text_to_send = req.user_prompt
        elif req.input_type == "text":
            text_to_send = req.content
        else:
            text_to_send = "Analyse ce fichier et réponds à ma question."

        parts.append({"text": text_to_send})

        # On ajoute le fichier (Image, Audio ou Vidéo) si ce n'est pas une requête pur texte
        if req.input_type != "text":
            parts.append({
                "inline_data": {
                    "mime_type": req.content_mime_type or "image/png",
                    "data": b64_data
                }
            })

        payload = {
            "contents": [{"parts": parts}],
            "generationConfig": {
                "temperature": float(req.temperature),
                "maxOutputTokens": int(req.max_tokens),
            }
        }

        async with httpx.AsyncClient(timeout=120.0) as client:
            try:
                r = await client.post(url, params=params, json=payload)
                data = r.json()
                
                if r.status_code != 200:
                    error_msg = data.get("error", {}).get("message", "Erreur Google")
                    raise ProviderRequestError(f"Gemini: {error_msg}")

                # 4. RÉCUPÉRATION DES TOKENS (usageMetadata)
                usage_info = data.get("usageMetadata", {})
                
                # 5. Extraction de la réponse texte
                text_response = data['candidates'][0]['content']['parts'][0]['text']

                return {
                    "choices": [{
                        "message": {
                            "content": text_response
                        }
                    }],
                    "usage": {
                        "prompt_tokens": usage_info.get("promptTokenCount", 0),
                        "completion_tokens": usage_info.get("candidatesTokenCount", 0),
                        "total_tokens": usage_info.get("totalTokenCount", 0)
                    }
                }
            except Exception as e:
                raise ProviderRequestError(f"Échec Gemini: {str(e)}")