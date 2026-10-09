from __future__ import annotations

from typing import Any, Literal, Optional

from pydantic import BaseModel, Field, model_validator

# --- CORRECTION ICI : Ajouter groq et gemini ---
ProviderName = Literal["openai", "openrouter", "groq", "gemini", "ollama", "llamacpp"]
InputType = Literal["text", "image", "audio", "video"]


class GenerationRequest(BaseModel):
    """Input JSON uniquement pour la génération IA."""

    provider: Optional[ProviderName] = Field(default=None, description="openai par défaut si absent")
    model: Optional[str] = Field(default=None, description="Obligatoire si provider=openrouter, groq ou gemini")
    input_type: InputType
    content: str = Field(description="Texte brut ou base64 (image/audio/video)")
    user_prompt: Optional[str] = None
    temperature: float = Field(default=0.7, ge=0.0, le=2.0)
    max_tokens: int = Field(default=500, ge=1, le=8192)

    # Optionnel (utile pour image/audio)
    content_mime_type: Optional[str] = Field(default=None, description="ex: image/png, audio/wav, video/mp4")
    audio_format: Optional[str] = Field(default=None, description="ex: wav, mp3")

    @model_validator(mode="after")
    def _validate_model_presence(self) -> "GenerationRequest":
        # On rend le modèle obligatoire pour tous sauf OpenAI (qui a un défaut)
        if self.provider in ["openrouter", "groq", "gemini"] and not self.model:
            raise ValueError(f"Le champ 'model' est obligatoire pour le fournisseur {self.provider}")
        return self


class Usage(BaseModel):
    prompt_tokens: int = 0
    completion_tokens: int = 0
    total_tokens: int = 0


class GenerationResponse(BaseModel):
    provider: str # On utilise str ici pour plus de souplesse en retour
    model: str
    raw_response: Any
    formatted_response: str
    usage: Usage
    cost_estimation: Optional[str] = None
    response_time_ms: int


class ProviderResult(BaseModel):
    """Schéma interne pour le retour des providers vers le service."""
    provider: str
    model: str
    raw_response: Any
    formatted_response: str
    usage: Optional[Usage] = None
    is_free: bool = False