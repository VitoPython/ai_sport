"""Сховище даних у MongoDB.

Колекції:
- workouts: тренування користувача (унікальні за (user_id, id))
- profiles: профіль користувача (цілі, рівень тощо)

AI-асистент читає ці дані через tool use (див. tools.py).
"""

from .db import db
from .schemas import WorkoutSync

_workouts = db["workouts"]
_profiles = db["profiles"]

# Проєкція: ховаємо службові поля Mongo у відповідях.
_HIDE = {"_id": 0, "user_id": 0}


def save_workouts(user_id: str, workouts: list[WorkoutSync]) -> int:
    """Зберегти тренування (ідемпотентно за (user_id, id)). Повертає кількість нових."""
    added = 0
    for w in workouts:
        result = _workouts.update_one(
            {"user_id": user_id, "id": w.id},
            {"$setOnInsert": {**w.model_dump(), "user_id": user_id}},
            upsert=True,
        )
        if result.upserted_id is not None:
            added += 1
    return added


def count_workouts(user_id: str) -> int:
    return _workouts.count_documents({"user_id": user_id})


def get_workouts(user_id: str, limit: int = 20) -> list[dict]:
    cursor = (
        _workouts.find({"user_id": user_id}, _HIDE)
        .sort("start_date", -1)
        .limit(limit)
    )
    return list(cursor)


def get_profile(user_id: str) -> dict:
    doc = _profiles.find_one({"user_id": user_id}, _HIDE)
    return doc or {"note": "Профіль ще не заповнено"}
