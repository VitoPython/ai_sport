"""Синхронізація тренувань з iOS-клієнта на бекенд (для контексту AI-асистента)."""

from fastapi import APIRouter

from ..schemas import WorkoutSync
from .. import store

router = APIRouter(prefix="/sync", tags=["sync"])


@router.post("/workouts")
def sync_workouts(user_id: str, workouts: list[WorkoutSync]) -> dict:
    added = store.save_workouts(user_id, workouts)
    return {"added": added, "total": len(store.get_workouts(user_id, limit=10_000))}


@router.get("/workouts")
def list_workouts(user_id: str, limit: int = 20) -> list[dict]:
    return store.get_workouts(user_id, limit)
