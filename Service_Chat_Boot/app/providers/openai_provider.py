from __future__ import annotations

from typing import Any

from app.adapters.openai_adapter import OpenAIAdapter
from app.config.settings import get_settings
from app.providers.base import AIProvider
from app.schemas.ai import GenerationRequest
from app.services.types import ProviderResult
from app.utils.tokenizer import extract_usage


class OpenAIProvider(AIProvider):
    name = "openai"

    def __init__(self) -> None:
        self._settings = get_settings()
        self._adapter = OpenAIAdapter()

    async def generate(self, req: GenerationRequest) -> ProviderResult:
        model = req.model or self._settings.openai_default_model
        payload = await self._adapter.create_response(model=model, req=req)
        text = _extract_openai_text(payload)
        usage = extract_usage(payload)
        return ProviderResult(
            provider="openai",
            model=model,
            raw_response=payload,
            formatted_response=text,
            usage=usage,
        )


def _extract_openai_text(payload: dict[str, Any]) -> str:
    """
    Responses API output:
    - output: [{content: [{type: 'output_text', text: '...'}]}]
    """

    chunks: list[str] = []
    for item in payload.get("output", []) or []:
        for c in item.get("content", []) or []:
            if c.get("type") == "output_text" and isinstance(c.get("text"), str):
                chunks.append(c["text"])
    return "\n".join([c for c in chunks if c]).strip()

