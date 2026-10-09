from __future__ import annotations

import logging

from fastapi import APIRouter, Query, Request, Response

from app.config.settings import get_settings
from app.services.whatsapp_cloud import is_cloud_configured, process_webhook_payload, verify_signature

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/whatsapp/meta", tags=["whatsapp-meta"])


@router.get("/webhook")
async def meta_webhook_verify(
    hub_mode: str | None = Query(default=None, alias="hub.mode"),
    hub_verify_token: str | None = Query(default=None, alias="hub.verify_token"),
    hub_challenge: str | None = Query(default=None, alias="hub.challenge"),
) -> Response:
    """Meta WhatsApp webhook verification (configure this URL in Meta Developer Console)."""
    settings = get_settings()
    if hub_mode == "subscribe" and hub_verify_token == settings.whatsapp_verify_token:
        return Response(content=hub_challenge or "", media_type="text/plain")
    return Response(status_code=403)


@router.post("/webhook")
async def meta_webhook_receive(request: Request) -> dict[str, str]:
    """
    Meta envoie ici les messages reçus sur le numéro business (+212689461643).
    L'IA répond automatiquement dans le chat WhatsApp de l'utilisateur.
    """
    raw = await request.body()
    sig = request.headers.get("X-Hub-Signature-256")
    if not verify_signature(raw, sig):
        logger.warning("Invalid Meta webhook signature")
        return {"status": "ignored"}

    import json

    body = json.loads(raw)
    if body.get("object") != "whatsapp_business_account":
        return {"status": "ignored"}

    await process_webhook_payload(body)
    return {"status": "ok"}
