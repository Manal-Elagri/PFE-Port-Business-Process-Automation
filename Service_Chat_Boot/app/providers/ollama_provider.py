from app.adapters.ollama_adapter import OllamaAdapter
from app.schemas.ai import GenerationRequest, ProviderResult, Usage

class OllamaProvider:
    def __init__(self):
        self._adapter = OllamaAdapter()

    async def generate(self, req: GenerationRequest) -> ProviderResult:
        # Modèle par défaut si l'utilisateur n'a rien choisi
        model = req.model or "qwen2.5:0.5b"
        
        raw = await self._adapter.chat_completions(model=model, req=req)
        
        usage_raw = raw.get("usage", {})
        usage = Usage(
            prompt_tokens=usage_raw.get("prompt_tokens", 0),
            completion_tokens=usage_raw.get("completion_tokens", 0),
            total_tokens=usage_raw.get("total_tokens", 0)
        )

        return ProviderResult(
            provider="ollama",
            model=model,
            raw_response=raw,
            formatted_response=raw["choices"][0]["message"]["content"],
            usage=usage,
            is_free=True
        )