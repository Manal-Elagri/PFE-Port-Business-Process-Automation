from __future__ import annotations

import math
from typing import Any, Optional

import tiktoken

from app.schemas.ai import InputType, Usage


def _encoding_for_model(model: str) -> tiktoken.Encoding:
    try:
        return tiktoken.encoding_for_model(model)
    except Exception:
        return tiktoken.get_encoding("cl100k_base")


def count_tokens_text(text: str, model: str) -> int:
    enc = _encoding_for_model(model)
    return len(enc.encode(text or ""))


def estimate_tokens_from_base64(b64: str) -> int:
    """
    Approximation when the provider does not return usage.
    base64_size_bytes ≈ len(b64) * 3/4
    tokens ≈ bytes / 4 (very rough)
    """

    if not b64:
        return 0
    bytes_len = (len(b64) * 3) / 4
    return int(math.ceil(bytes_len / 4))


def fallback_usage(
    *,
    input_type: InputType,
    model: str,
    prompt_content: str,
    completion_text: str,
) -> Usage:
    # 1. Estimation des tokens pour le PROMPT (l'entrée)
    if input_type == "text":
        prompt_tokens = count_tokens_text(prompt_content, model)
    elif input_type == "video":
        # Estimation forfaitaire pour la vidéo (comme tu l'as demandé)
        # 1000 tokens est une base raisonnable pour une courte vidéo
        prompt_tokens = 1000
    else:
        # Pour "image" et "audio", on reste sur l'estimation via la taille du Base64
        prompt_tokens = estimate_tokens_from_base64(prompt_content)

    # 2. Estimation des tokens pour la RÉPONSE (toujours du texte)
    completion_tokens = count_tokens_text(completion_text, model) if completion_text else 0
    
    # Si c'est une vidéo et que la réponse est vide (bug), on peut mettre tes 200 tokens
    if input_type == "video" and completion_tokens == 0:
        completion_tokens = 200

    return Usage(
        prompt_tokens=prompt_tokens,
        completion_tokens=completion_tokens,
        total_tokens=prompt_tokens + completion_tokens,
    )


def extract_usage(payload: Any) -> Optional[Usage]:
    """Try to parse token usage from provider JSON payload."""

    if not isinstance(payload, dict):
        return None

    usage = payload.get("usage")
    if not isinstance(usage, dict):
        return None

    pt = usage.get("prompt_tokens")
    ct = usage.get("completion_tokens")
    tt = usage.get("total_tokens")

    if isinstance(pt, int) and isinstance(ct, int):
        if not isinstance(tt, int):
            tt = pt + ct
        return Usage(prompt_tokens=pt, completion_tokens=ct, total_tokens=tt)

    # Some providers use different names
    input_tokens = usage.get("input_tokens")
    output_tokens = usage.get("output_tokens")
    total_tokens = usage.get("total_tokens")
    if isinstance(input_tokens, int) and isinstance(output_tokens, int):
        if not isinstance(total_tokens, int):
            total_tokens = input_tokens + output_tokens
        return Usage(prompt_tokens=input_tokens, completion_tokens=output_tokens, total_tokens=total_tokens)

    return None

