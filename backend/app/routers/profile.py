"""Профіль користувача: цілі, рівень підготовки тощо (контекст для AI-асистента)."""

from fastapi import APIRouter

from ..schemas import Profile
from .. import store

router = APIRouter(prefix="/profile", tags=["profile"])


@router.get("")
def read_profile(user_id: str) -> dict:
    return store.get_profile(user_id)


@router.put("")
def update_profile(user_id: str, profile: Profile) -> dict:
    # Зберігаємо лише передані (не None) поля — часткове оновлення.
    store.save_profile(user_id, profile.model_dump(exclude_none=True))
    return store.get_profile(user_id)
