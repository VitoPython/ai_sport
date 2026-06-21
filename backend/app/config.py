from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Налаштування бекенду з .env."""

    anthropic_api_key: str = ""
    claude_model: str = "claude-opus-4-8"
    allowed_origins: str = "*"

    # MongoDB
    mongo_url: str = "mongodb://localhost:27017"
    mongo_db: str = "ai_sport"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    @property
    def origins_list(self) -> list[str]:
        return [o.strip() for o in self.allowed_origins.split(",") if o.strip()]


settings = Settings()
