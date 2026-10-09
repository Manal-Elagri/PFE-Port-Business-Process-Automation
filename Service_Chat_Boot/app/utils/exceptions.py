from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Optional


@dataclass(slots=True)
class AppError(Exception):
    """Base class for domain/application errors returned as JSON."""

    message: str
    code: str = "app_error"
    status_code: int = 400
    details: Optional[dict[str, Any]] = None


class UnauthorizedError(AppError):
    def __init__(self, message: str = "Unauthorized"):
        super().__init__(message=message, code="unauthorized", status_code=401)


class ProviderConfigError(AppError):
    def __init__(self, message: str, details: Optional[dict[str, Any]] = None):
        super().__init__(message=message, code="provider_config_error", status_code=500, details=details)


class ProviderRequestError(AppError):
    def __init__(self, message: str, details: Optional[dict[str, Any]] = None, status_code: int = 502):
        super().__init__(message=message, code="provider_request_error", status_code=status_code, details=details)


class ValidationAppError(AppError):
    def __init__(self, message: str, details: Optional[dict[str, Any]] = None):
        super().__init__(message=message, code="validation_error", status_code=422, details=details)

