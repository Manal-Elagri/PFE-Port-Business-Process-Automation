from __future__ import annotations

from typing import Type
# On importe les providers existants
from app.providers.openai_provider import OpenAIProvider
from app.providers.openrouter_provider import OpenRouterProvider
# --- ON AJOUTE LES NOUVEAUX ---
from app.providers.groq_provider import GroqProvider
from app.providers.gemini_provider import GeminiProvider
from app.providers.ollama_provider import OllamaProvider # À ajouter
from app.providers.llamacpp_provider import LlamaCppProvider

# Dictionnaire qui fait le lien entre le nom reçu (ex: "gemini") et la Classe Python
PROVIDERS: dict[str, Type] = {
    "openai": OpenAIProvider,
    "openrouter": OpenRouterProvider,
    "groq": GroqProvider,
    "gemini": GeminiProvider, # <-- Ajouté
    "ollama": OllamaProvider, # <-- Ajouté ici
    "llamacpp": LlamaCppProvider, # <-- AJOUTE CETTE LIGNE
}

def get_provider(name: str):
    """
    Récupère l'instance du fournisseur demandée.
    """
    # On met en minuscule pour éviter les erreurs de frappe (ex: "Groq" ou "groq")
    provider_class = PROVIDERS.get(name.lower())
    
    if not provider_class:
        # Si le fournisseur n'existe pas dans la liste ci-dessus
        raise ValueError(f"Le fournisseur '{name}' n'est pas supporté par ce microservice.")
    
    return provider_class()