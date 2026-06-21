"""Калорії по фото: фото страви → калорії та БЖВ через Claude (multimodal)."""

import base64

import anthropic
from fastapi import APIRouter, File, UploadFile, HTTPException

from ..claude_client import client, MODEL
from ..schemas import FoodAnalysis

router = APIRouter(prefix="/vision", tags=["nutrition"])

PROMPT = (
    "Проаналізуй фото страви. Визнач страви/інгредієнти та оціни харчову цінність. "
    "Поверни калорії та БЖВ (білки/жири/вуглеводи) для кожної позиції та сумарно. "
    "Оцінюй порції розумно; якщо щось неоднозначне — познач у notes."
)

_MEDIA_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/gif",
}


@router.post("", response_model=FoodAnalysis)
async def analyze_food(photo: UploadFile = File(...)) -> FoodAnalysis:
    media_type = photo.content_type or "image/jpeg"
    if media_type not in _MEDIA_TYPES:
        raise HTTPException(status_code=400, detail=f"Непідтримуваний формат: {media_type}")

    data = await photo.read()
    b64 = base64.standard_b64encode(data).decode("utf-8")

    # Structured output: модель повертає рівно структуру FoodAnalysis.
    try:
        response = client.messages.parse(
            model=MODEL,
            max_tokens=2048,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": media_type,
                                "data": b64,
                            },
                        },
                        {"type": "text", "text": PROMPT},
                    ],
                }
            ],
            output_format=FoodAnalysis,
        )
    except anthropic.BadRequestError as e:
        # Напр. зображення замале/пошкоджене — це проблема вводу, не сервера.
        raise HTTPException(status_code=400, detail=f"Не вдалося обробити зображення: {e.message}") from e
    except anthropic.APIError as e:
        raise HTTPException(status_code=502, detail=f"Помилка Claude API: {e}") from e

    if response.parsed_output is None:
        raise HTTPException(status_code=502, detail="Не вдалося розпізнати страву")
    return response.parsed_output
