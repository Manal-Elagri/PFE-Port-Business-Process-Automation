from __future__ import annotations

from functools import lru_cache
from typing import Literal

from pydantic import AnyHttpUrl, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # Service
    service_name: str = Field(default="ai-microservice", alias="SERVICE_NAME")
    service_env: Literal["dev", "staging", "prod"] = Field(default="dev", alias="SERVICE_ENV")
    service_log_level: str = Field(default="INFO", alias="SERVICE_LOG_LEVEL")
    service_api_key: str = Field(default="change-me", alias="SERVICE_API_KEY")
    service_rate_limit: str = Field(default="30/minute", alias="SERVICE_RATE_LIMIT")
    jwt_secret_key: str = Field(default="", alias="JWT_SECRET_KEY")
    java_backend_base_url: str = Field(
        default="http://localhost:8080",
        alias="JAVA_BACKEND_BASE_URL",
    )

    # OpenAI
    openai_api_key: str = Field(default="", alias="OPENAI_API_KEY")
    openai_base_url: AnyHttpUrl = Field(default="https://api.openai.com/v1", alias="OPENAI_BASE_URL")
    openai_default_model: str = Field(default="gpt-4o-mini", alias="OPENAI_DEFAULT_MODEL")

    # OpenRouter
    openrouter_api_key: str = Field(default="", alias="OPENROUTER_API_KEY")
    openrouter_base_url: AnyHttpUrl = Field(default="https://openrouter.ai/api/v1", alias="OPENROUTER_BASE_URL")
    openrouter_default_model: str = Field(default="", alias="OPENROUTER_DEFAULT_MODEL")
    openrouter_site_url: str = Field(default="http://localhost", alias="OPENROUTER_SITE_URL")
    openrouter_app_name: str = Field(default="ai-microservice", alias="OPENROUTER_APP_NAME")

    # Groq (AJOUTÉ)
    groq_api_key: str = Field(default="", alias="GROQ_API_KEY")
    groq_default_model: str = Field(default="llama-3.3-70b-versatile", alias="GROQ_DEFAULT_MODEL")

    # Gemini (AJOUTÉ)
    # Gemini
    gemini_api_key: str = Field(default="", alias="GEMINI_API_KEY")
    gemini_default_model: str = Field(default="gemini-2.5-flash", alias="GEMINI_DEFAULT_MODEL")

    # Platform / RAG / WhatsApp
    whatsapp_phone: str = Field(default="212689461643", alias="WHATSAPP_PHONE")
    knowledge_base_dir: str = Field(default="knowledge_base", alias="KNOWLEDGE_BASE_DIR")
    rag_default_provider: str = Field(default="groq", alias="RAG_DEFAULT_PROVIDER")
    rag_default_model: str = Field(default="llama-3.3-70b-versatile", alias="RAG_DEFAULT_MODEL")
    rag_max_context_chars: int = Field(default=12000, alias="RAG_MAX_CONTEXT_CHARS")

    whatsapp_driver: str = Field(default="neonize", alias="WHATSAPP_DRIVER")
    whatsapp_auto_reply_enabled: bool = Field(default=True, alias="WHATSAPP_AUTO_REPLY_ENABLED")
    whatsapp_show_admin: bool = Field(default=False, alias="WHATSAPP_SHOW_ADMIN")

    # Meta WhatsApp Cloud API (numéro business = intermédiaire, comme un bot Meta)
    whatsapp_cloud_token: str = Field(default="", alias="WHATSAPP_CLOUD_TOKEN")
    whatsapp_phone_number_id: str = Field(default="", alias="WHATSAPP_PHONE_NUMBER_ID")
    whatsapp_verify_token: str = Field(default="change-me-verify", alias="WHATSAPP_VERIFY_TOKEN")
    whatsapp_app_secret: str = Field(default="", alias="WHATSAPP_APP_SECRET")
    whatsapp_session_name: str = Field(default="ai_platform_session", alias="WHATSAPP_SESSION_NAME")
    whatsapp_session_db: str = Field(default="data/whatsapp_neonize.db", alias="WHATSAPP_SESSION_DB")
    whatsapp_ignore_groups: bool = Field(default=True, alias="WHATSAPP_IGNORE_GROUPS")
    whatsapp_ai_provider: str = Field(default="groq", alias="WHATSAPP_AI_PROVIDER")
    whatsapp_ai_model: str = Field(default="llama-3.3-70b-versatile", alias="WHATSAPP_AI_MODEL")
    whatsapp_history_db: str = Field(default="data/whatsapp_history.db", alias="WHATSAPP_HISTORY_DB")
    whatsapp_rules_file: str = Field(default="config/whatsapp_rules.json", alias="WHATSAPP_RULES_FILE")

@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return a cached Settings instance."""

    return Settings()