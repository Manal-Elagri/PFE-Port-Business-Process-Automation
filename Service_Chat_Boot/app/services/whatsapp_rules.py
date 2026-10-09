from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

from pydantic import BaseModel, Field

from app.config.settings import get_settings


class WhatsAppRule(BaseModel):
    match: str
    reply: str | None = None
    exact: bool = False
    use_ai: bool = False


class WhatsAppRulesConfig(BaseModel):
    enabled: bool = True
    system_prompt: str = ""
    rules: list[WhatsAppRule] = Field(default_factory=list)
    default_use_ai: bool = True


def _rules_path() -> Path:
    settings = get_settings()
    p = Path(settings.whatsapp_rules_file)
    if not p.is_absolute():
        p = Path(__file__).resolve().parent.parent.parent / p
    return p


def load_rules() -> WhatsAppRulesConfig:
    path = _rules_path()
    if not path.is_file():
        return WhatsAppRulesConfig()
    data = json.loads(path.read_text(encoding="utf-8"))
    return WhatsAppRulesConfig.model_validate(data)


def save_rules(config: WhatsAppRulesConfig) -> None:
    path = _rules_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(config.model_dump_json(indent=2), encoding="utf-8")


def match_rule(user_text: str, config: WhatsAppRulesConfig) -> WhatsAppRule | None:
    text = user_text.strip().lower()
    for rule in config.rules:
        pattern = rule.match.strip().lower()
        if rule.exact and text == pattern:
            return rule
        if not rule.exact and pattern in text:
            return rule
    return None


def resolve_reply(user_text: str, config: WhatsAppRulesConfig) -> tuple[bool, str | None]:
    """Return (use_ai, static_reply). static_reply set when rule provides fixed text."""
    if not config.enabled:
        return config.default_use_ai, None
    rule = match_rule(user_text, config)
    if rule is None:
        return config.default_use_ai, None
    if rule.use_ai:
        return True, None
    if rule.reply:
        return False, rule.reply
    return config.default_use_ai, None
