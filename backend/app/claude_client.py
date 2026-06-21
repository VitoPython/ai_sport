import anthropic

from .config import settings

# Єдиний клієнт Claude на весь застосунок.
# Ключ береться з ANTHROPIC_API_KEY (через .env / середовище).
client = anthropic.Anthropic(api_key=settings.anthropic_api_key or None)

MODEL = settings.claude_model
