"""AI-асистент: чат із Claude + tool use (доступ до тренувань/профілю)."""

import anthropic
from fastapi import APIRouter, HTTPException

from ..claude_client import client, MODEL
from ..schemas import ChatRequest, ChatResponse
from ..tools import TOOLS, run_tool

router = APIRouter(prefix="/chat", tags=["assistant"])

SYSTEM_PROMPT = (
    "Ти — персональний AI спортивний асистент. Допомагаєш користувачу з бігом, "
    "тренуваннями, відновленням і харчуванням. Спілкуйся українською, дружньо й по суті. "
    "Коли потрібні дані про тренування чи профіль користувача — використовуй інструменти. "
    "Даєш практичні, безпечні поради; при складанні програм враховуй рівень і відновлення. "
    "Не вигадуй медичних діагнозів; за тривожних симптомів радь звернутися до лікаря."
)

MAX_TOOL_ITERATIONS = 5


@router.post("", response_model=ChatResponse)
def chat(req: ChatRequest) -> ChatResponse:
    user_id = req.user_id or "demo"
    messages = [{"role": m.role, "content": m.content} for m in req.messages]

    # Ручний agentic-цикл: крутимо, доки Claude викликає інструменти.
    for _ in range(MAX_TOOL_ITERATIONS):
        try:
            response = client.messages.create(
                model=MODEL,
                max_tokens=4096,
                system=SYSTEM_PROMPT,
                thinking={"type": "adaptive"},
                tools=TOOLS,
                messages=messages,
            )
        except anthropic.APIError as e:
            raise HTTPException(status_code=502, detail=f"Помилка Claude API: {e}") from e

        if response.stop_reason != "tool_use":
            break

        # Додаємо відповідь асистента (з tool_use блоками) у історію.
        messages.append({"role": "assistant", "content": response.content})

        # Виконуємо всі запитані інструменти й повертаємо результати.
        tool_results = []
        for block in response.content:
            if block.type == "tool_use":
                result = run_tool(block.name, block.input, user_id)
                tool_results.append(
                    {
                        "type": "tool_result",
                        "tool_use_id": block.id,
                        "content": result,
                    }
                )
        messages.append({"role": "user", "content": tool_results})

    reply = next((b.text for b in response.content if b.type == "text"), "")
    return ChatResponse(reply=reply)
