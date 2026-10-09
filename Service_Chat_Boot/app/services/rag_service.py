from __future__ import annotations

from app.config.settings import get_settings
from app.schemas.ai import GenerationRequest
from app.services.generation_service import GenerationService
from app.services.rag_prompt import build_rag_prompt


async def answer_with_docs(user_message: str) -> str:
    settings = get_settings()
    prompt = build_rag_prompt(user_message)
    req = GenerationRequest(
        provider=settings.rag_default_provider,  # type: ignore[arg-type]
        model=settings.rag_default_model,
        input_type="text",
        content=prompt,
        temperature=0.3,
        max_tokens=1024,
    )
    result = await GenerationService().generate(req, apply_rag=False)
    return result.formatted_response
