from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Optional

from app.schemas.ai import ProviderName, Usage


@dataclass(slots=True)
class ProviderResult:
    provider: ProviderName
    model: str
    raw_response: Any
    formatted_response: str
    usage: Optional[Usage] = None
    is_free: bool = False

