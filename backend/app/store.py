"""Тимчасове сховище даних у пам'яті.

Заглушка на час Фази 1–2. На Фазі 2+ замінимо на SQLite/Postgres.
Тренування надсилає сюди iOS-клієнт через /sync; AI-асистент читає їх через tool use.
"""

from .schemas import WorkoutSync

# user_id -> список тренувань
_workouts: dict[str, list[WorkoutSync]] = {}

# Дуже спрощений профіль користувача (заглушка).
_profiles: dict[str, dict] = {}


def save_workouts(user_id: str, workouts: list[WorkoutSync]) -> int:
    bucket = _workouts.setdefault(user_id, [])
    existing = {w.id for w in bucket}
    added = 0
    for w in workouts:
        if w.id not in existing:
            bucket.append(w)
            added += 1
    return added


def get_workouts(user_id: str, limit: int = 20) -> list[dict]:
    bucket = _workouts.get(user_id, [])
    recent = sorted(bucket, key=lambda w: w.start_date, reverse=True)[:limit]
    return [w.model_dump() for w in recent]


def get_profile(user_id: str) -> dict:
    return _profiles.get(user_id, {"note": "Профіль ще не заповнено"})
