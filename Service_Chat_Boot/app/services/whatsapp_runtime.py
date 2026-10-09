from __future__ import annotations

from app.config.settings import get_settings
from app.services.whatsapp_cloud import is_cloud_configured


def effective_driver() -> str:
    """cloud = API Meta uniquement ; neonize = opt-in explicite (non utilisé par défaut)."""
    driver = (get_settings().whatsapp_driver or "cloud").lower()
    if driver == "neonize":
        return "neonize"
    return "cloud"


def should_start_neonize_bot() -> bool:
    settings = get_settings()
    if not settings.whatsapp_auto_reply_enabled:
        return False
    return effective_driver() == "neonize"
