from __future__ import annotations

import io

import qrcode

from app.config.settings import get_settings
from app.schemas.ai import GenerationRequest
from app.schemas.platform import WhatsAppStatusResponse
from app.services.generation_service import GenerationService
from app.services.rag_service import answer_with_docs
from app.state import runtime


def get_whatsapp_status() -> WhatsAppStatusResponse:
    settings = get_settings()
    phone = settings.whatsapp_phone.lstrip("+").replace(" ", "")
    formatted = f"+{phone[:3]} {phone[3:6]} {phone[6:]}" if len(phone) > 6 else f"+{phone}"
    return WhatsAppStatusResponse(
        phone=phone,
        display=f"Actif sur {formatted}",
        wa_link=f"https://wa.me/{phone}",
    )


def generate_contact_qr_png() -> bytes:
    status = get_whatsapp_status()
    qr = qrcode.QRCode(version=1, box_size=10, border=4)
    qr.add_data(status.wa_link)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    buffer = io.BytesIO()
    img.save(buffer, format="PNG")
    return buffer.getvalue()


def generate_qr_png() -> bytes:
    """Backward-compatible: contact link QR."""
    return generate_contact_qr_png()


async def handle_webhook_message(message: str) -> str:
    if runtime.current_mode == "docs":
        return await answer_with_docs(message)

    settings = get_settings()
    req = GenerationRequest(
        provider=settings.rag_default_provider,  # type: ignore[arg-type]
        model=settings.rag_default_model,
        input_type="text",
        content=message,
        temperature=0.7,
        max_tokens=1024,
    )
    result = await GenerationService().generate(req)
    return result.formatted_response
