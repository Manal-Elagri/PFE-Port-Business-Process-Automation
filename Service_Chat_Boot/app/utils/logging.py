from __future__ import annotations

import logging
import sys


def configure_logging(level: str = "INFO") -> None:
    """Configure structured-ish logging suitable for containers."""

    logging.basicConfig(
        level=getattr(logging, level.upper(), logging.INFO),
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
        stream=sys.stdout,
    )

