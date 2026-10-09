from __future__ import annotations

from typing import Optional

import httpx


def build_async_client(*, base_url: str, timeout_s: float = 60.0) -> httpx.AsyncClient:
    return httpx.AsyncClient(
        base_url=base_url,
        timeout=httpx.Timeout(timeout_s),
        headers={"accept": "application/json"},
    )


def redact_auth_headers(headers: dict[str, str]) -> dict[str, str]:
    redacted = dict(headers)
    if "authorization" in redacted:
        redacted["authorization"] = "REDACTED"
    return redacted

