from __future__ import annotations

from pathlib import Path

from app.config.settings import get_settings


def get_session_db_path() -> Path:
    """Chemin fixe de la base Neonize/whatsmeow (session = scan QR une seule fois)."""
    settings = get_settings()
    rel = (getattr(settings, "whatsapp_session_db", None) or "data/whatsapp_neonize.db").strip()
    path = Path(rel)
    if not path.is_absolute():
        path = Path(__file__).resolve().parent.parent.parent / path
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def session_exists() -> bool:
    path = get_session_db_path()
    return path.is_file() and path.stat().st_size > 512
