from __future__ import annotations

import logging
import time

from app.config.settings import get_settings
from app.providers.registry import get_provider
from app.schemas.ai import GenerationRequest, GenerationResponse
from app.services.rag_prompt import build_rag_prompt
from app.services.types import ProviderResult
from app.state import runtime
from app.utils.cost import estimate_cost_usd
from app.utils.exceptions import ProviderRequestError
from app.utils.metrics import METRICS
from app.utils.tokenizer import fallback_usage

logger = logging.getLogger(__name__)

_DEFAULT_MODELS: dict[str, str] = {
    "groq": "llama-3.3-70b-versatile",
    "gemini": "gemini-2.5-flash",
}


def _provider_chain(primary: str) -> list[str]:
    order = [primary, "groq", "gemini"]
    seen: set[str] = set()
    out: list[str] = []
    for name in order:
        if name not in seen:
            seen.add(name)
            out.append(name)
    return out


def _model_for(provider: str, req: GenerationRequest, settings) -> str:
    if req.model and provider == (req.provider or provider):
        return req.model
    if provider == "groq":
        return settings.groq_default_model or _DEFAULT_MODELS["groq"]
    if provider == "gemini":
        return settings.gemini_default_model or _DEFAULT_MODELS["gemini"]
    if provider == "openai":
        return req.model or settings.openai_default_model
    return req.model or _DEFAULT_MODELS["groq"]


class GenerationService:
    """Application service for text/image/audio generation."""

    async def generate(self, req: GenerationRequest, *, apply_rag: bool = True) -> GenerationResponse:
        if apply_rag and runtime.current_mode == "docs" and req.input_type == "text":
            user_message = req.content
            req = req.model_copy(update={"content": build_rag_prompt(user_message)})

        settings = get_settings()
        primary = req.provider or settings.rag_default_provider or "groq"
        last_exc: Exception | None = None
        result: ProviderResult | None = None
        start = time.perf_counter()

        for provider_name in _provider_chain(primary):
            attempt = req.model_copy(
                update={
                    "provider": provider_name,  # type: ignore[arg-type]
                    "model": _model_for(provider_name, req, settings),
                }
            )
            try:
                provider = get_provider(provider_name)
                result = await provider.generate(attempt)
                if provider_name != primary:
                    logger.warning("Failover IA: %s -> %s", primary, provider_name)
                break
            except ProviderRequestError as exc:
                last_exc = exc
                logger.warning("Provider %s failed: %s", provider_name, exc.message)
                continue

        if result is None:
            if isinstance(last_exc, ProviderRequestError):
                raise last_exc
            raise ProviderRequestError("Aucun fournisseur IA disponible")

        elapsed_ms = int((time.perf_counter() - start) * 1000)

        usage = result.usage or fallback_usage(
            input_type=req.input_type,
            model=result.model,
            prompt_content=req.content,
            completion_text=result.formatted_response,
        )

        cost = estimate_cost_usd(result.provider, result.model, usage, is_free=result.is_free)

        METRICS.record(provider=result.provider, model=result.model, total_tokens=usage.total_tokens)

        return GenerationResponse(
            provider=result.provider,
            model=result.model,
            raw_response=result.raw_response,
            formatted_response=result.formatted_response,
            usage=usage,
            cost_estimation=cost,
            response_time_ms=elapsed_ms,
        )

