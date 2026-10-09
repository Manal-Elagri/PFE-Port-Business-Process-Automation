from __future__ import annotations

from app.config.settings import get_settings
from app.services.document_service import extract_text_from_kb


def build_rag_prompt(user_message: str) -> str:
    settings = get_settings()
    context = extract_text_from_kb()
    if not context.strip():
        context = "(Aucun document disponible dans la base de connaissances.)"
    max_chars = settings.rag_max_context_chars
    if len(context) > max_chars:
        context = context[:max_chars] + "\n...[tronqué]"

    return f"""Contexte (documents locaux):
{context}

Question: {user_message}

Réponds en te basant sur le contexte ci-dessus. Si l'information n'est pas dans le contexte, dis-le clairement."""
