from __future__ import annotations

import hashlib
import hmac
import logging
from typing import Any

import httpx

from app.config.settings import get_settings
from app.services.whatsapp_ai_reply import generate_whatsapp_reply
from app.services.whatsapp_history import save_message

logger = logging.getLogger(__name__)

GRAPH_API = "https://graph.facebook.com/v21.0"


def is_cloud_configured() -> bool:
    s = get_settings()
    return bool(s.whatsapp_cloud_token and s.whatsapp_phone_number_id)


def verify_signature(payload: bytes, signature_header: str | None) -> bool:
    settings = get_settings()
    secret = settings.whatsapp_app_secret.strip()
    if not secret or not signature_header:
        return not secret
    if not signature_header.startswith("sha256="):
        return False
    expected = hmac.new(secret.encode(), payload, hashlib.sha256).hexdigest()
    return hmac.compare_digest(signature_header[7:], expected)


async def send_text_message(to_wa_id: str, text: str) -> dict[str, Any]:
    """Send a text message via WhatsApp Cloud API. to_wa_id = phone digits only (e.g. 2126...)."""
    settings = get_settings()
    if not is_cloud_configured():
        raise RuntimeError("WhatsApp Cloud API non configurée dans .env")

    url = f"{GRAPH_API}/{settings.whatsapp_phone_number_id}/messages"
    headers = {
        "Authorization": f"Bearer {settings.whatsapp_cloud_token}",
        "Content-Type": "application/json",
    }
    payload = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": to_wa_id.lstrip("+"),
        "type": "text",
        "text": {"preview_url": False, "body": text[:4096]},
    }
    async with httpx.AsyncClient(timeout=60.0) as client:
        r = await client.post(url, headers=headers, json=payload)
        if r.status_code >= 400:
            logger.error("WhatsApp send failed: %s", r.text)
            r.raise_for_status()
        return r.json()


def _extract_incoming_messages(body: dict[str, Any]) -> list[dict[str, Any]]:
    """Parse Meta webhook payload into normalized message dicts."""
    results: list[dict[str, Any]] = []
    for entry in body.get("entry", []):
        for change in entry.get("changes", []):
            value = change.get("value", {})
            contacts = {c.get("wa_id"): c.get("profile", {}).get("name") for c in value.get("contacts", [])}
            for msg in value.get("messages", []):
                wa_id = msg.get("from", "")
                name = contacts.get(wa_id, "")
                mtype = msg.get("type", "text")
                text = ""
                media_id = None
                mime = None
                if mtype == "text":
                    text = msg.get("text", {}).get("body", "")
                elif mtype in ("image", "video", "audio", "document"):
                    media = msg.get(mtype, {})
                    media_id = media.get("id")
                    text = media.get("caption", "") or f"[{mtype}]"
                    mime = media.get("mime_type")
                results.append(
                    {
                        "wa_id": wa_id,
                        "name": name,
                        "message_id": msg.get("id"),
                        "type": mtype,
                        "text": text,
                        "media_id": media_id,
                        "mime": mime,
                    }
                )
    return results


async def _download_media(media_id: str) -> tuple[bytes, str]:
    settings = get_settings()
    headers = {"Authorization": f"Bearer {settings.whatsapp_cloud_token}"}
    async with httpx.AsyncClient(timeout=120.0) as client:
        meta = await client.get(f"{GRAPH_API}/{media_id}", headers=headers)
        meta.raise_for_status()
        url = meta.json().get("url")
        if not url:
            raise RuntimeError("Media URL missing")
        blob = await client.get(url, headers=headers)
        blob.raise_for_status()
        mime = blob.headers.get("content-type", "application/octet-stream")
        return blob.content, mime


async def process_webhook_payload(body: dict[str, Any]) -> None:
    """Receive user messages on business number → AI → reply on WhatsApp."""
    for item in _extract_incoming_messages(body):
        wa_id = item["wa_id"]
        user_text = (item["text"] or "").strip()
        chat_jid = f"{wa_id}@s.whatsapp.net"
        mtype = item["type"]
        input_type = "text"
        content: str | None = None
        mime = item.get("mime")

        if mtype in ("image", "video", "audio") and item.get("media_id"):
            try:
                import base64

                raw, mime = await _download_media(item["media_id"])
                content = base64.b64encode(raw).decode("ascii")
                input_type = mtype if mtype in ("image", "video", "audio") else "text"
                if not user_text:
                    user_text = f"[{mtype}]"
            except Exception as exc:
                logger.warning("Cloud media download failed: %s", exc)

        if not user_text and not content:
            continue

        save_message(
            chat_jid=chat_jid,
            direction="in",
            body=user_text,
            source="WHATSAPP",
            sender_jid=chat_jid,
            push_name=item.get("name"),
            media_type=mtype if mtype != "text" else None,
            wa_message_id=item.get("message_id"),
        )

        try:
            reply = await generate_whatsapp_reply(
                user_text,
                chat_jid,
                input_type=input_type,  # type: ignore[arg-type]
                content=content,
                content_mime_type=mime,
                user_prompt=user_text if input_type != "text" else None,
            )
            await send_text_message(wa_id, reply)
            save_message(chat_jid=chat_jid, direction="out", body=reply, source="WHATSAPP")
            logger.info("Cloud auto-reply sent to %s", wa_id)
        except Exception as exc:
            logger.exception("Cloud auto-reply failed: %s", exc)
