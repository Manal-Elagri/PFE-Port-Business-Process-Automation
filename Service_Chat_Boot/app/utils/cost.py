from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

from app.schemas.ai import Usage


@dataclass(frozen=True, slots=True)
class ModelPricing:
    prompt_per_1m_usd: float
    completion_per_1m_usd: float


# NOTE: Pricing changes over time. Keep this small and optional.
OPENAI_PRICING: dict[str, ModelPricing] = {
    # Reasonable defaults; update when needed.
    "gpt-4.1-mini": ModelPricing(prompt_per_1m_usd=0.15, completion_per_1m_usd=0.60),
    "gpt-4.1": ModelPricing(prompt_per_1m_usd=2.50, completion_per_1m_usd=10.00),
}


def estimate_cost_usd(provider: str, model: str, usage: Usage, is_free: bool = False) -> Optional[str]:
    if is_free:
        return "$0.00 (free)"

    if provider != "openai":
        return None

    pricing = OPENAI_PRICING.get(model)
    if pricing is None:
        return None

    cost = (usage.prompt_tokens * pricing.prompt_per_1m_usd + usage.completion_tokens * pricing.completion_per_1m_usd) / 1_000_000
    return f"${cost:.6f}"

