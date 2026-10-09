from __future__ import annotations

from fastapi import APIRouter, Depends, Query

from app.providers.registry import get_provider
from app.utils.security import require_service_api_key

router = APIRouter(
    prefix="/v1/openrouter",
    tags=["openrouter"],
    dependencies=[Depends(require_service_api_key)],
)


@router.get("/models")
async def list_openrouter_models(
    free_only: bool = Query(default=True, description="Retourne uniquement les modèles gratuits"),
) -> dict[str, object]:
    """
    Récupère dynamiquement les modèles OpenRouter.
    Le microservice filtre par défaut sur les modèles Free.
    """

    provider = get_provider("openrouter")
    models = await provider.list_models() or []
    if free_only:
        models = [m for m in models if m.get("is_free") is True]
    return {"provider": "openrouter", "free_only": free_only, "models": models}

