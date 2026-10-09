from __future__ import annotations

import logging
from typing import Any

import httpx
from tenacity import retry, retry_if_exception, stop_after_attempt, wait_exponential_jitter

from app.adapters.http import build_async_client
from app.config.settings import get_settings
from app.schemas.ai import GenerationRequest
from app.utils.exceptions import ProviderConfigError, ProviderRequestError

logger = logging.getLogger(__name__)


class OpenAIAdapter:
    """HTTP adapter for OpenAI official API (Responses)."""

    def __init__(self) -> None:
        self._settings = get_settings()
        if not self._settings.openai_api_key:
            raise ProviderConfigError("OPENAI_API_KEY is missing")
        self._client = build_async_client(base_url=str(self._settings.openai_base_url))

    async def aclose(self) -> None:
        await self._client.aclose()

    def _auth_headers(self) -> dict[str, str]:
        return {"authorization": f"Bearer {self._settings.openai_api_key}"}

    def _build_input(self, req: GenerationRequest) -> list[dict[str, Any]]:
        if req.input_type == "text":
            content: list[dict[str, Any]] = [{"type": "input_text", "text": req.content}]
        elif req.input_type == "image":
            mime = req.content_mime_type or "image/png"
            data_url = f"data:{mime};base64,{req.content}"
            content = [{"type": "input_image", "image_url": data_url}]
        else:
            fmt = req.audio_format or "wav"
            content = [{"type": "input_audio", "input_audio": {"data": req.content, "format": fmt}}]

        return [{"role": "user", "content": content}]

    @retry(
        stop=stop_after_attempt(2),
        wait=wait_exponential_jitter(initial=0.2, max=1.0),
        retry=retry_if_exception(lambda e: isinstance(e, httpx.RequestError)),
        reraise=True,
    )
    async def create_response(self, *, model: str, req: GenerationRequest) -> dict[str, Any]:
        payload: dict[str, Any] = {
            "model": model,
            "input": self._build_input(req),
            "temperature": req.temperature,
            "max_output_tokens": req.max_tokens,
        }

        try:
            r = await self._client.post("/responses", headers=self._auth_headers(), json=payload)
        except httpx.RequestError as e:
            raise ProviderRequestError("OpenAI request failed", details={"reason": str(e)}) from e

        if r.status_code >= 400:
            if r.status_code == 429:
                raise ProviderRequestError(
                    "OpenAI : quota ou limite de requêtes dépassée (429). "
                    "Utilisez Groq/Gemini dans le chat ou vérifiez votre compte OpenAI.",
                    status_code=429,
                    details={"status_code": r.status_code, "body": _safe_json(r)},
                )
            raise ProviderRequestError(
                "OpenAI returned an error",
                status_code=502,
                details={"status_code": r.status_code, "body": _safe_json(r)},
            )

        return r.json()


def _safe_json(resp: httpx.Response) -> Any:
    try:
        return resp.json()
    except Exception:
        return resp.text[:2000]

