from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

SearchMode = Literal["web", "docs"]


class ModeResponse(BaseModel):
    mode: SearchMode


class ModeRequest(BaseModel):
    mode: SearchMode


class DocumentInfo(BaseModel):
    name: str
    size_bytes: int
    modified_at: str


class DocumentsListResponse(BaseModel):
    files: list[DocumentInfo]


class UploadResponse(BaseModel):
    uploaded: list[str]
    count: int


class WebhookRequest(BaseModel):
    message: str = Field(min_length=1)


class WebhookResponse(BaseModel):
    reply: str
    mode: SearchMode


class WhatsAppStatusResponse(BaseModel):
    phone: str
    display: str
    wa_link: str
    connection_state: str = "disconnected"
    connected: bool = False
    auto_reply_enabled: bool = True
    driver: str = "neonize"
    error: str | None = None
    user_action: str | None = None
    needs_business_setup: bool = False
    meta_configured: bool = False
    show_admin_panel: bool = False
    session_saved: bool = False


class WhatsAppHistoryResponse(BaseModel):
    messages: list[dict]


class WhatsAppConversationsResponse(BaseModel):
    conversations: list[dict]


class WhatsAppRulesResponse(BaseModel):
    enabled: bool
    system_prompt: str
    rules: list[dict]
    default_use_ai: bool
