from __future__ import annotations

from fastapi import APIRouter, Depends, File, Query, UploadFile
from fastapi.responses import Response

from app.schemas.platform import (
    DocumentsListResponse,
    ModeRequest,
    ModeResponse,
    UploadResponse,
    WebhookRequest,
    WebhookResponse,
    WhatsAppConversationsResponse,
    WhatsAppHistoryResponse,
    WhatsAppRulesResponse,
    WhatsAppStatusResponse,
)
from app.services import document_service
from app.services.whatsapp_bot_manager import get_enhanced_status, get_whatsapp_bot
from app.services.whatsapp_service import generate_contact_qr_png
from app.services.whatsapp_rules import WhatsAppRule, WhatsAppRulesConfig, load_rules, save_rules
from app.services.whatsapp_service import handle_webhook_message
from app.state import runtime
from app.utils.security import require_service_api_key

router = APIRouter(
    prefix="/v1",
    tags=["platform"],
    dependencies=[Depends(require_service_api_key)],
)


@router.get("/mode", response_model=ModeResponse)
async def get_mode() -> ModeResponse:
    return ModeResponse(mode=runtime.current_mode)


@router.post("/mode", response_model=ModeResponse)
async def set_mode(body: ModeRequest) -> ModeResponse:
    runtime.current_mode = body.mode
    return ModeResponse(mode=runtime.current_mode)


@router.get("/documents", response_model=DocumentsListResponse)
async def list_documents() -> DocumentsListResponse:
    return DocumentsListResponse(files=document_service.list_documents())


@router.post("/upload", response_model=UploadResponse)
async def upload_documents(files: list[UploadFile] = File(...)) -> UploadResponse:
    uploaded: list[str] = []
    for file in files:
        name = await document_service.save_upload(file)
        uploaded.append(name)
    return UploadResponse(uploaded=uploaded, count=len(uploaded))


@router.get("/whatsapp/status", response_model=WhatsAppStatusResponse)
async def whatsapp_status() -> WhatsAppStatusResponse:
    data = await get_enhanced_status()
    return WhatsAppStatusResponse(**data)


@router.get("/whatsapp/qr")
async def whatsapp_qr(qr_type: str = Query(default="contact")) -> Response:
    """
    contact = QR wa.me pour les utilisateurs finaux.
    setup = QR Neonize (admin uniquement, téléphone +212 689 461 643).
    """
    if qr_type == "setup":
        bot = get_whatsapp_bot()
        if bot.is_connected():
            return Response(
                status_code=400,
                content=b"Already connected",
                media_type="text/plain",
            )
        if bot.state.value in ("disconnected", "error"):
            await bot.start()
        png = await bot.get_pairing_qr_png()
        if not png:
            return Response(status_code=404, content=b"QR not ready", media_type="text/plain")
        return Response(content=png, media_type="image/png", headers={"X-QR-Type": "setup"})
    png = generate_contact_qr_png()
    return Response(content=png, media_type="image/png", headers={"X-QR-Type": "contact"})


@router.post("/whatsapp/connect")
async def whatsapp_connect() -> dict:
    """Démarre / relance la session Neonize sur le numéro business +212."""
    bot = get_whatsapp_bot()
    if not bot.is_connected():
        await bot.start()
    data = await get_enhanced_status()
    return {"ok": True, **data}


@router.post("/whatsapp/disconnect")
async def whatsapp_disconnect() -> dict:
    bot = get_whatsapp_bot()
    await bot.stop()
    return {"ok": True, "connection_state": "disconnected"}


@router.post("/whatsapp/reset-session")
async def whatsapp_reset_session() -> dict:
    """Efface la session Neonize (apres 401) et affiche un nouveau QR admin."""
    bot = get_whatsapp_bot()
    await bot.reset_session()
    data = await get_enhanced_status()
    return {"ok": True, **data}


@router.get("/whatsapp/history", response_model=WhatsAppHistoryResponse)
async def whatsapp_history(
    chat_jid: str | None = Query(default=None),
    limit: int = Query(default=100, ge=1, le=500),
) -> WhatsAppHistoryResponse:
    from app.services.whatsapp_history import list_messages

    return WhatsAppHistoryResponse(messages=list_messages(chat_jid=chat_jid, limit=limit))


@router.get("/whatsapp/conversations", response_model=WhatsAppConversationsResponse)
async def whatsapp_conversations(limit: int = Query(default=50, ge=1, le=200)) -> WhatsAppConversationsResponse:
    from app.services.whatsapp_history import list_conversations

    return WhatsAppConversationsResponse(conversations=list_conversations(limit=limit))


@router.get("/whatsapp/rules", response_model=WhatsAppRulesResponse)
async def get_rules() -> WhatsAppRulesResponse:
    cfg = load_rules()
    return WhatsAppRulesResponse(
        enabled=cfg.enabled,
        system_prompt=cfg.system_prompt,
        rules=[r.model_dump() for r in cfg.rules],
        default_use_ai=cfg.default_use_ai,
    )


@router.put("/whatsapp/rules", response_model=WhatsAppRulesResponse)
async def put_rules(body: WhatsAppRulesResponse) -> WhatsAppRulesResponse:
    cfg = WhatsAppRulesConfig(
        enabled=body.enabled,
        system_prompt=body.system_prompt,
        rules=[WhatsAppRule.model_validate(r) for r in body.rules],
        default_use_ai=body.default_use_ai,
    )
    save_rules(cfg)
    return body


@router.post("/whatsapp/webhook", response_model=WebhookResponse)
async def whatsapp_webhook(body: WebhookRequest) -> WebhookResponse:
    reply = await handle_webhook_message(body.message)
    return WebhookResponse(reply=reply, mode=runtime.current_mode)
