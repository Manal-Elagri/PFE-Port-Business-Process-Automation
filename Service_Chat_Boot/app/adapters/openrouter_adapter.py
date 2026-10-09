from __future__ import annotations
from typing import Any
import httpx
import logging
from tenacity import retry, stop_after_attempt, wait_exponential_jitter
from app.config.settings import get_settings
from app.schemas.ai import GenerationRequest
from app.utils.exceptions import ProviderConfigError, ProviderRequestError, ValidationAppError

logger = logging.getLogger(__name__)

class OpenRouterAdapter:
    def __init__(self) -> None:
        self._settings = get_settings()
        # Nettoyage de la clé
        raw_key = str(self._settings.openrouter_api_key or "").strip()
        self.api_key = raw_key.replace("\r", "").replace("\n", "").replace('"', '').strip()
        
        if not self.api_key or "sk-or" not in self.api_key:
            raise ProviderConfigError("La clé OPENROUTER_API_KEY est invalide.")

    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self.api_key}",
            "HTTP-Referer": "http://localhost:8000",
            "X-Title": "AI-Microservice",
            "Content-Type": "application/json",
        }

    def _build_messages(self, req: GenerationRequest) -> list[dict[str, Any]]:
        """Construit le message selon le type d'input (Texte, Image, Audio, Vidéo)"""
        # 1. Cas du texte simple
        if req.input_type == "text":
            return [{"role": "user", "content": req.content}]
        
        # 2. Cas Multimodal (Image, Audio, Vidéo)
        # Détermination du MimeType automatique si absent
        mime = req.content_mime_type
        if not mime:
            if req.input_type == "image": mime = "image/png"
            elif req.input_type == "audio": mime = "audio/mp3"
            elif req.input_type == "video": mime = "video/mp4"

        # Format standard supporté par OpenRouter/Gemini pour les fichiers
        return [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": "Analyse ce fichier et réponds à ma question."},
                    {
                        "type": "image_url", # Note: OpenRouter utilise souvent image_url pour tout type de média base64
                        "image_url": {
                            "url": f"data:{mime};base64,{req.content}"
                        }
                    }
                ]
            }
        ]

    @retry(stop=stop_after_attempt(2), wait=wait_exponential_jitter(initial=0.5, max=2.0))
    async def chat_completions(self, *, model: str, req: GenerationRequest) -> dict[str, Any]:
        url = "https://openrouter.ai/api/v1/chat/completions"
        
        # Utilisation de la fonction de construction dynamique
        payload = {
            "model": model.strip(),
            "messages": self._build_messages(req), # CORRECTION ICI
            "temperature": float(req.temperature or 0.7),
            "max_tokens": int(req.max_tokens or 500)
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            try:
                r = await client.post(url, headers=self._headers(), json=payload)
                if r.status_code >= 400:
                    error_data = _safe_json(r)
                    error_msg = error_data.get("error", {}).get("message", r.text)
                    print(f"\n[DEBUG] ERREUR {r.status_code}: {error_msg}\n")
                    raise ProviderRequestError(f"OpenRouter Error: {error_msg}", status_code=r.status_code)
                return r.json()
            except Exception as e:
                if "OpenRouter Error" in str(e): raise e
                raise ProviderRequestError(f"Erreur connexion : {str(e)}")

    async def list_models(self) -> dict[str, Any]:
        url = "https://openrouter.ai/api/v1/models"
        async with httpx.AsyncClient() as client:
            r = await client.get(url, headers=self._headers())
            return r.json()

def _safe_json(resp: httpx.Response) -> Any:
    try:
        return resp.json()
    except:
        return {"raw": resp.text[:500]}