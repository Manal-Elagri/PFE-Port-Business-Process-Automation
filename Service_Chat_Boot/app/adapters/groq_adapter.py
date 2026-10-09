from __future__ import annotations
from typing import Any  # <-- Répare "Any" is not defined
import httpx            # <-- Répare "httpx" is not defined
from app.config.settings import get_settings
from app.schemas.ai import GenerationRequest


class GroqAdapter:
    def __init__(self) -> None:
        self._settings = get_settings()
        self.api_key = str(self._settings.groq_api_key).strip()

    async def chat_completions(self, *, model: str, req: GenerationRequest) -> dict[str, Any]:
        url = "https://api.groq.com/openai/v1/chat/completions"
        headers = {"Authorization": f"Bearer {self.api_key}", "Content-Type": "application/json"}
        payload = {
            "model": model or "llama-3.3-70b-versatile",
            "messages": [{"role": "user", "content": req.content}],
            "temperature": req.temperature
        }
        timeout = httpx.Timeout(90.0, connect=30.0)
        async with httpx.AsyncClient(timeout=timeout) as client:
            r = await client.post(url, headers=headers, json=payload)
            r.raise_for_status()
            return r.json()