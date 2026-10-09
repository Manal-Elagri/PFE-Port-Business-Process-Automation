from app.adapters.llamacpp_adapter import LlamaCppAdapter
from app.schemas.ai import GenerationRequest, ProviderResult, Usage

class LlamaCppProvider:
    def __init__(self):
        self._adapter = LlamaCppAdapter()

    async def generate(self, req: GenerationRequest) -> ProviderResult:
        # On appelle l'IA
        raw = await self._adapter.chat_completions(model="local", req=req)
        
        # Extraction des données
        content = raw["choices"][0]["message"]["content"]
        usage_raw = raw.get("usage", {})

        return ProviderResult(
            provider="llamacpp",
            model="Qwen-0.5B (llama.cpp)",
            raw_response=raw,
            formatted_response=content,
            usage=Usage(
                prompt_tokens=usage_raw.get("prompt_tokens", 0),
                completion_tokens=usage_raw.get("completion_tokens", 0),
                total_tokens=usage_raw.get("total_tokens", 0)
            ),
            is_free=True
        )