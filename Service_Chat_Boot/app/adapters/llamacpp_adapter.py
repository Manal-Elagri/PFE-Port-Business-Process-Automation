from __future__ import annotations
from typing import Any
import httpx
from app.schemas.ai import GenerationRequest
from app.utils.exceptions import ProviderRequestError

class LlamaCppAdapter:
    def __init__(self) -> None:
        # On utilise l'URL locale du serveur llama.cpp
        self.url = "http://127.0.0.1:8001/v1/chat/completions"

    async def chat_completions(self, *, model: str, req: GenerationRequest) -> dict[str, Any]:
        payload = {
            "messages": [{"role": "user", "content": req.content}],
            "temperature": req.temperature,
            "max_tokens": req.max_tokens,
            "stream": False
        }
        async with httpx.AsyncClient(timeout=120.0) as client:
            try:
                r = await client.post(self.url, json=payload)
                if r.status_code != 200:
                    raise ProviderRequestError(f"Llama.cpp Error: {r.text}")
                return r.json()
            except Exception as e:
                raise ProviderRequestError(f"Serveur llama.cpp non détecté : {str(e)}")