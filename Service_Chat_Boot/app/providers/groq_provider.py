from app.adapters.groq_adapter import GroqAdapter
from app.schemas.ai import GenerationRequest, ProviderResult

class GroqProvider:
    def __init__(self):
        self._adapter = GroqAdapter()

    async def generate(self, req: GenerationRequest) -> ProviderResult:
        model = req.model or "llama-3.3-70b-versatile"
        raw = await self._adapter.chat_completions(model=model, req=req)
        
        return ProviderResult(
            provider="groq",
            model=model,
            raw_response=raw,
            formatted_response=raw["choices"][0]["message"]["content"],
            usage=raw.get("usage"),
            is_free=True # Groq a un large plan gratuit
        )