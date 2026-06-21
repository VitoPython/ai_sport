"""Підключення до MongoDB.

URL і назва БД беруться з .env / середовища (MONGO_URL, MONGO_DB).
Локально — Mongo з docker-compose.local.yml; на Dokploy — окремий Database-сервіс.
"""

from pymongo import MongoClient

from .config import settings

# Клієнт ледачий: реальне з'єднання встановлюється при першому запиті,
# тож імпорт не падає, навіть якщо Mongo ще недоступна.
_client: MongoClient = MongoClient(settings.mongo_url, serverSelectionTimeoutMS=3000)
db = _client[settings.mongo_db]


def ping_db() -> bool:
    """Перевірка доступності Mongo (для /health)."""
    try:
        _client.admin.command("ping")
        return True
    except Exception:
        return False
