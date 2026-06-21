"""Інструменти (tool use) для AI-асистента.

Claude вирішує, коли викликати інструмент; бекенд виконує його (читає дані
користувача зі сховища) і повертає результат назад у модель.
"""

import json

from . import store

# Описи інструментів для Claude. Описуємо ЯК і КОЛИ використовувати —
# свіжіші моделі Opus викликають інструменти стриманіше, тож умова виклику важлива.
TOOLS = [
    {
        "name": "get_workouts",
        "description": (
            "Отримати останні тренування користувача (біг/ходьба) з метриками. "
            "Викликай, коли користувач питає про свої тренування, прогрес, "
            "навантаження або просить скласти програму на основі історії."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "limit": {
                    "type": "integer",
                    "description": "Скільки останніх тренувань повернути (за замовчуванням 20)",
                }
            },
            "required": [],
        },
    },
    {
        "name": "get_profile",
        "description": (
            "Отримати профіль користувача (цілі, рівень підготовки тощо). "
            "Викликай, коли потрібен контекст про людину для поради чи плану."
        ),
        "input_schema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
]


def run_tool(name: str, tool_input: dict, user_id: str) -> str:
    """Виконати інструмент і повернути результат як рядок (JSON)."""
    if name == "get_workouts":
        limit = int(tool_input.get("limit", 20))
        return json.dumps(store.get_workouts(user_id, limit), ensure_ascii=False)
    if name == "get_profile":
        return json.dumps(store.get_profile(user_id), ensure_ascii=False)
    return json.dumps({"error": f"Невідомий інструмент: {name}"}, ensure_ascii=False)
