import logging

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.services.whatsapp_bot_manager import get_whatsapp_bot
from app.utils.security import require_service_api_key

from neonize.utils import jid as jid_util

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/v1/notifications", tags=["Notifications"])


class WhatsAppPayload(BaseModel):
    destinataire: str = Field(alias="phone")
    message: str

    model_config = {
        "populate_by_name": True,
    }


def normalize_phone(phone: str) -> str:
    normalized = "".join(ch for ch in phone if ch.isdigit())

    if normalized.startswith("00"):
        normalized = normalized[2:]

    if normalized.startswith("0") and len(normalized) == 10:
        normalized = "212" + normalized[1:]
    elif len(normalized) == 9:
        normalized = "212" + normalized

    return normalized


def phone_to_jid(phone: str):
    normalized = normalize_phone(phone)
    return jid_util.build_jid(normalized, "s.whatsapp.net")


@router.post("/send-whatsapp", dependencies=[Depends(require_service_api_key)])
async def send_whatsapp_notif(request: WhatsAppPayload):
    wa_bot = get_whatsapp_bot()
    try:
        if not wa_bot.is_connected():
            raise HTTPException(status_code=503, detail="WhatsApp Bot non connecté")

        print("DESTINATAIRE RAW:", request.destinataire)
        normalized = normalize_phone(request.destinataire)
        print("DESTINATAIRE NORMALISE:", normalized)

        jid = phone_to_jid(request.destinataire)
        print("JID:", jid_util.Jid2String(jid))

        await wa_bot._client.send_message(jid, request.message)

        return {"status": "sent", "to": jid_util.Jid2String(jid)}
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Erreur envoi WhatsApp: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e
