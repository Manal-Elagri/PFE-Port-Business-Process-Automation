from __future__ import annotations
import httpx
import logging
from typing import Any

from app.config.settings import get_settings
from app.schemas.ai import GenerationRequest
from app.services.generation_service import GenerationService
from app.services.rag_service import answer_with_docs
from app.services.whatsapp_history import recent_context
from app.services.whatsapp_rules import load_rules, resolve_reply
from app.state import runtime

logger = logging.getLogger(__name__)

_DEFAULT_MODELS: dict[str, str] = {
    "groq": "llama-3.3-70b-versatile",
    "gemini": "gemini-2.5-flash",
}


def _provider_chain() -> list[tuple[str, str]]:
    settings = get_settings()
    raw = (settings.whatsapp_ai_provider or "groq,gemini").strip()
    names = [p.strip().lower() for p in raw.split(",") if p.strip()]
    if not names:
        names = ["groq", "gemini"]

    chain: list[tuple[str, str]] = []
    primary_model = (settings.whatsapp_ai_model or "").strip()
    for i, name in enumerate(names):
        if name == "groq" and i == 0 and primary_model:
            model = primary_model
        elif name == "gemini":
            model = settings.gemini_default_model or _DEFAULT_MODELS["gemini"]
        else:
            model = _DEFAULT_MODELS.get(name, primary_model or "llama-3.3-70b-versatile")
        chain.append((name, model))
    return chain


def _build_prompt(
    user_text: str,
    chat_jid: str,
    *,
    history: list[dict[str, str]] | None = None,
) -> str:
    rules = load_rules()
    history = history if history is not None else recent_context(chat_jid, limit=8)
    lines = [rules.system_prompt.strip()] if rules.system_prompt.strip() else []
    if history:
        lines.append("\nHistorique récent :")
        for h in history[-8:]:
            role = "Client" if h["role"] == "user" else "Assistant"
            lines.append(f"{role}: {h['content']}")
    lines.append(f"\nMessage actuel du client : {user_text}")
    lines.append("\nRéponds maintenant de façon naturelle (message WhatsApp court si possible) :")
    return "\n".join(lines)


def _build_request(
    provider: str,
    model: str,
    *,
    input_type: str,
    body: str,
    user_prompt: str | None,
    content_mime_type: str | None,
) -> GenerationRequest:
    return GenerationRequest(
        provider=provider,  # type: ignore[arg-type]
        model=model,
        input_type=input_type,  # type: ignore[arg-type]
        content=body,
        user_prompt=user_prompt if input_type != "text" else None,
        content_mime_type=content_mime_type,
        temperature=0.7,
        max_tokens=1024,
    )


async def _generate_with_failover(req: GenerationRequest) -> str:
    chain = _provider_chain()
    last_error: Exception | None = None

    for provider, model in chain:
        try:
            attempt = req.model_copy(update={"provider": provider, "model": model})  # type: ignore[arg-type]
            result = await GenerationService().generate(attempt, apply_rag=False)
            logger.info("WhatsApp IA: reponse via %s (%s)", provider, model)
            return result.formatted_response
        except Exception as exc:
            last_error = exc
            logger.warning("WhatsApp IA: echec %s (%s): %s", provider, model, exc)

    if last_error:
        raise last_error
    raise RuntimeError("Aucun fournisseur IA disponible")


async def generate_whatsapp_reply(
    user_text: str,
    chat_jid: str,
    *,
    input_type: str = "text",
    content: str | None = None,
    content_mime_type: str | None = None,
    user_prompt: str | None = None,
) -> str:
    rules = load_rules()
    use_ai, static = resolve_reply(user_text, rules)
    if static and not use_ai:
        return static

    if runtime.current_mode == "docs" and input_type == "text":
        return await answer_with_docs(user_text)

    prompt = _build_prompt(user_text, chat_jid) if input_type == "text" else (user_prompt or user_text)
    body = content if content and input_type != "text" else prompt

    req = _build_request(
        "groq",
        _DEFAULT_MODELS["groq"],
        input_type=input_type,
        body=body,
        user_prompt=user_prompt if input_type != "text" else None,
        content_mime_type=content_mime_type,
    )
    return await _generate_with_failover(req)

async def get_java_user_id(phone_number: str) -> int:
    # On appelle un endpoint interne de ton Spring Boot
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"http://localhost:8080/api/internal/user-by-phone/{phone_number}")
        if resp.status_code == 200:
            return resp.json().get("id")
    return None 