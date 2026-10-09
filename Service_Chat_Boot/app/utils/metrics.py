from __future__ import annotations

from dataclasses import dataclass, field
from threading import Lock


@dataclass
class UsageMetrics:
    """In-memory metrics (basic monitoring)."""

    requests_total: int = 0
    tokens_total: int = 0
    by_provider: dict[str, int] = field(default_factory=dict)
    by_model: dict[str, int] = field(default_factory=dict)
    _lock: Lock = field(default_factory=Lock, repr=False)

    def record(self, provider: str, model: str, total_tokens: int) -> None:
        with self._lock:
            self.requests_total += 1
            self.tokens_total += int(total_tokens or 0)
            self.by_provider[provider] = self.by_provider.get(provider, 0) + 1
            self.by_model[model] = self.by_model.get(model, 0) + 1

    def snapshot(self) -> dict[str, object]:
        with self._lock:
            return {
                "requests_total": self.requests_total,
                "tokens_total": self.tokens_total,
                "by_provider": dict(self.by_provider),
                "by_model": dict(self.by_model),
            }


METRICS = UsageMetrics()

