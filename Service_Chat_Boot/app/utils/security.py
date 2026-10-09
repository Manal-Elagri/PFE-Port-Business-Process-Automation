from __future__ import annotations

import jwt
from fastapi import Header
from jwt.exceptions import DecodeError, ExpiredSignatureError, InvalidTokenError

from app.config.settings import get_settings
from app.utils.exceptions import UnauthorizedError


async def require_service_api_key(x_api_key: str | None = Header(default=None, alias="X-API-Key")):
    settings = get_settings()

    print("🔥 RECEIVED API KEY =", x_api_key)
    print("🔥 EXPECTED API KEY =", settings.service_api_key)

    if not settings.service_api_key:
        raise UnauthorizedError("Service API key is not configured")

    if x_api_key != settings.service_api_key:
        print("❌ KEY MISMATCH")
        raise UnauthorizedError()

def _strip_bearer_prefix(token: str) -> str:
    raw = token.strip()
    if raw.lower().startswith("bearer "):
        return raw[7:].strip()
    return raw


def get_user_id_from_jwt(token: str) -> int:
    """Decode a Java HS256 JWT and return user id from the ``sub`` claim (string -> int)."""
    settings = get_settings()
    if not settings.jwt_secret_key:
        raise UnauthorizedError("JWT secret is not configured")

    try:
        payload = jwt.decode(
            _strip_bearer_prefix(token),
            settings.jwt_secret_key,
            algorithms=["HS256"],
        )
        sub = payload.get("sub")
        if sub is None:
            raise UnauthorizedError("JWT missing sub claim")
        return int(sub)
    except (InvalidTokenError, DecodeError, ExpiredSignatureError) as exc:
        raise UnauthorizedError(f"Invalid JWT: {exc}") from exc
    except (TypeError, ValueError) as exc:
        raise UnauthorizedError(f"Invalid JWT sub claim: {exc}") from exc


def get_user_id_from_token(token: str) -> int:
    """Alias for backward compatibility."""
    return get_user_id_from_jwt(token)
