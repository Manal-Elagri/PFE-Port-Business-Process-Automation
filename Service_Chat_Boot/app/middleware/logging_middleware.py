from __future__ import annotations

import logging
import time
import uuid

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

logger = logging.getLogger("app.request")


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Log request/response with latency and correlation id."""

    async def dispatch(self, request: Request, call_next) -> Response:
        request_id = request.headers.get("x-request-id") or str(uuid.uuid4())
        start = time.perf_counter()
        response: Response | None = None
        try:
            response = await call_next(request)
            if response is not None:
                response.headers["x-request-id"] = request_id
            return response
        finally:
            elapsed_ms = int((time.perf_counter() - start) * 1000)
            logger.info(
                "%s %s -> %s (%sms) rid=%s",
                request.method,
                request.url.path,
                response.status_code if response is not None else "ERR",
                elapsed_ms,
                request_id,
            )

