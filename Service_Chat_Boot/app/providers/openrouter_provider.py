from __future__ import annotations

from typing import Any

from app.adapters.openrouter_adapter import OpenRouterAdapter
from app.providers.base import AIProvider
from app.schemas.ai import GenerationRequest
from app.services.types import ProviderResult
from app.utils.tokenizer import extract_usage


class OpenRouterProvider(AIProvider):
    name = "openrouter"

    def __init__(self) -> None:
        self._adapter = OpenRouterAdapter()
        self._free_models: set[str] = set()

    async def generate(self, req: GenerationRequest) -> ProviderResult:
        # Schema already enforces model required for openrouter
        model = req.model or ""
        payload = await self._adapter.chat_completions(model=model, req=req)
        text = _extract_openrouter_text(payload)
        usage = extract_usage(payload)
        return ProviderResult(
            provider="openrouter",
            model=model,
            raw_response=payload,
            formatted_response=text,
            usage=usage,
            is_free=self.is_free_model(model),
        )

    async def list_models(self) -> list[dict[str, Any]]:
        payload = await self._adapter.list_models()
        models = payload.get("data") if isinstance(payload, dict) else None
        if not isinstance(models, list):
            return []

        normalized: list[dict[str, Any]] = []
        free_models: set[str] = set()

        for m in models:
            if not isinstance(m, dict):
                continue
            mid = m.get("id")
            if not isinstance(mid, str):
                continue
            pricing = m.get("pricing") if isinstance(m.get("pricing"), dict) else {}
            is_free = _is_free_pricing(pricing)
            if is_free:
                free_models.add(mid)

            normalized.append(
                {
                    "id": mid,
                    "name": m.get("name") or mid,
                    "context_length": m.get("context_length"),
                    "is_free": is_free,
                    "pricing": pricing,
                }
            )

        self._free_models = free_models
        return normalized

    def is_free_model(self, model: str) -> bool:
        return model in self._free_models


def _is_free_pricing(pricing: dict[str, Any]) -> bool:
    # OpenRouter commonly returns pricing as strings (USD per token).
    prompt = pricing.get("prompt")
    completion = pricing.get("completion")

    def _to_float(x: Any) -> float | None:
        try:
            return float(x)
        except Exception:
            return None

    p = _to_float(prompt)
    c = _to_float(completion)
    return (p == 0.0) and (c == 0.0)


def _extract_openrouter_text(payload: dict[str, Any]) -> str:
    # OpenAI-compatible: choices[0].message.content
    choices = payload.get("choices")
    if not isinstance(choices, list) or not choices:
        return ""
    msg = choices[0].get("message") if isinstance(choices[0], dict) else None
    if not isinstance(msg, dict):
        return ""
    content = msg.get("content")
    if isinstance(content, str):
        return content.strip()
    # Some models may return array content
    if isinstance(content, list):
        parts: list[str] = []
        for p in content:
            if isinstance(p, dict) and isinstance(p.get("text"), str):
                parts.append(p["text"])
        return "\n".join(parts).strip()
    return ""

