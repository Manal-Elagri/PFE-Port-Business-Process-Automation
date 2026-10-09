from __future__ import annotations
from typing import Any
import httpx
from app.config.settings import get_settings
from app.schemas.ai import GenerationRequest
from app.utils.exceptions import ProviderRequestError

class OllamaAdapter:
    def __init__(self) -> None:
        self.base_url = "http://localhost:11434/api/chat"

    async def chat_completions(self, *, model: str, req: GenerationRequest) -> dict[str, Any]:
        # Payload au format Ollama
        payload = {
            "model": model, # Sera 'qwen2.5:0.5b' ou 'deepseek-r1:1.5b'
            "messages": [{"role": "user", "content": req.content}],
            "stream": False,
            "options": {
                "temperature": req.temperature,
                "num_predict": req.max_tokens
            }
        }

        async with httpx.AsyncClient(timeout=120.0) as client:
            try:
                r = await client.post(self.base_url, json=payload)
                data = r.json()
                
                if r.status_code != 200:
                    raise ProviderRequestError(f"Ollama Error: {data.get('error')}")

                # On convertit le format Ollama vers ton format interne
                return {
                    "choices": [{"message": {"content": data["message"]["content"]}}],
                    "usage": {
                        "prompt_tokens": data.get("prompt_eval_count", 0),
                        "completion_tokens": data.get("eval_count", 0),
                        "total_tokens": data.get("prompt_eval_count", 0) + data.get("eval_count", 0)
                    }
                }
            except Exception as e:
                raise ProviderRequestError(f"Ollama non détecté sur le port 11434: {str(e)}")