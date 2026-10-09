from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any, Optional

from app.schemas.ai import GenerationRequest
from app.services.types import ProviderResult


class AIProvider(ABC):
    """Strategy interface for AI providers."""

    name: str

    @abstractmethod
    async def generate(self, req: GenerationRequest) -> ProviderResult:
        """Generate a response for the given request."""

    async def list_models(self) -> Optional[list[dict[str, Any]]]:
        """Optionally list available models for this provider."""

        return None

