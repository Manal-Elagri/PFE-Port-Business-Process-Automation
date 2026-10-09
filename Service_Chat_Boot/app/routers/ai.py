from __future__ import annotations

from fastapi import APIRouter, Depends, Header

from app.schemas.ai import GenerationRequest, GenerationResponse
from app.services.generation_service import GenerationService
from app.services.whatsapp_history import save_message
from app.utils.security import get_user_id_from_jwt, require_service_api_key

router = APIRouter(
    prefix="/v1",
    tags=["ai"],
    dependencies=[Depends(require_service_api_key)],
)


def _user_message_body(req: GenerationRequest) -> str:
    if req.input_type != "text" and req.user_prompt:
        return req.user_prompt.strip()
    return (req.content or "").strip()


@router.post("/generate", response_model=GenerationResponse)
async def generate(
    req: GenerationRequest,
    authorization: str | None = Header(default=None, alias="Authorization"),
) -> GenerationResponse:
    """
    Génération IA. ``X-API-Key`` obligatoire.
    Si ``Authorization: Bearer <JWT>`` (claim ``sub``), historique unifié PLATFORM.
    """
    user_id: int | None = None
    if authorization:
        user_id = get_user_id_from_jwt(authorization)
        chat_jid = f"UI_{user_id}"
        user_body = _user_message_body(req)
        if user_body:
            save_message(
                chat_jid=chat_jid,
                direction="in",
                body=user_body,
                user_id=user_id,
                source="PLATFORM",
            )

    result = await GenerationService().generate(req)

    if user_id is not None:
        save_message(
            chat_jid=f"UI_{user_id}",
            direction="out",
            body=result.formatted_response,
            user_id=user_id,
            source="PLATFORM",
        )

    return result
