from __future__ import annotations

from fastapi import APIRouter, Depends

from app.utils.metrics import METRICS
from app.utils.security import require_service_api_key

router = APIRouter(tags=["monitoring"], dependencies=[Depends(require_service_api_key)])


@router.get("/metrics")
async def metrics() -> dict[str, object]:
    """Basic JSON metrics (in-memory)."""

    return METRICS.snapshot()

