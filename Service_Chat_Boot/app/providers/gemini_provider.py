from app.adapters.gemini_adapter import GeminiAdapter
from app.schemas.ai import GenerationRequest, ProviderResult

class GeminiProvider:
    def __init__(self):
        self._adapter = GeminiAdapter()

    async def generate(self, req: GenerationRequest) -> ProviderResult:
        # On choisit le modèle flash par défaut pour la vidéo/audio
        model = req.model or "gemini-1.5-flash" 
        
        raw = await self._adapter.generate_content(model=model, req=req)
        
        return ProviderResult(
            provider="gemini",
            model=model,
            raw_response=raw,
            formatted_response=raw["choices"][0]["message"]["content"],
            usage=raw.get("usage"),
            is_free=True # Version gratuite de Google AI Studio
        )