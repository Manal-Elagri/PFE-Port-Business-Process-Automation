from __future__ import annotations

import logging
from typing import Any

from fastapi import Request
from fastapi.responses import ORJSONResponse
from slowapi.errors import RateLimitExceeded

from tenacity import RetryError

from app.utils.exceptions import AppError

logger = logging.getLogger(__name__)


async def app_error_handler(request: Request, exc: AppError) -> ORJSONResponse:
    payload: dict[str, Any] = {"error": {"code": exc.code, "message": exc.message}}
    if exc.details is not None:
        payload["error"]["details"] = exc.details
    return ORJSONResponse(status_code=exc.status_code, content=payload)


async def rate_limit_handler(request: Request, exc: RateLimitExceeded) -> ORJSONResponse:
    return ORJSONResponse(
        status_code=429,
        content={"error": {"code": "rate_limited", "message": "Too many requests"}},
        headers=getattr(exc, "headers", None) or {},
    )


async def retry_error_handler(request: Request, exc: RetryError) -> ORJSONResponse:
    """Expose la vraie erreur provider après épuisement des retries Tenacity."""
    cause: Exception | None = None
    if exc.last_attempt.failed:
        cause = exc.last_attempt.exception()
    if isinstance(cause, AppError):
        return await app_error_handler(request, cause)
    if isinstance(cause, Exception):
        return ORJSONResponse(
            status_code=502,
            content={
                "error": {
                    "code": "provider_request_error",
                    "message": str(cause),
                }
            },
        )
    return ORJSONResponse(
        status_code=502,
        content={"error": {"code": "provider_request_error", "message": "Provider request failed"}},
    )


async def http_exception_handler(request: Request, exc: Exception) -> ORJSONResponse:
    logger.exception("Unhandled error: %s %s", request.method, request.url.path)
    return ORJSONResponse(
        status_code=500,
        content={"error": {"code": "internal_error", "message": "Internal server error"}},
    )

