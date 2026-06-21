# Backend — AI Sport Assistant API

FastAPI-бекенд: AI-асистент на Claude (tool use), калорії по фото (Claude vision),
синхронізація тренувань.

## Запуск (Windows / будь-яка ОС)

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate          # Windows  (Linux/Mac: source .venv/bin/activate)
pip install -r requirements.txt
copy .env.example .env          # Windows  (Linux/Mac: cp) → впиши ANTHROPIC_API_KEY
uvicorn app.main:app --reload
```

Документація API (Swagger): http://127.0.0.1:8000/docs

## Ендпоінти

| Метод | Шлях | Призначення |
|---|---|---|
| GET | `/health` | Перевірка стану + поточна модель |
| POST | `/chat` | AI-асистент (Claude + tool use) |
| POST | `/vision` | Фото страви → калорії та БЖВ |
| POST | `/sync/workouts?user_id=...` | Прийняти тренування з iOS |
| GET | `/sync/workouts?user_id=...` | Список тренувань користувача |

## Структура

```
app/
├─ main.py          точка входу FastAPI, CORS, роутери
├─ config.py        налаштування з .env
├─ claude_client.py єдиний клієнт Claude
├─ schemas.py       Pydantic-моделі запитів/відповідей
├─ store.py         тимчасове сховище в пам'яті (заміна на БД у Фазі 2+)
├─ tools.py         інструменти для AI-асистента (get_workouts, get_profile)
└─ routers/         chat / vision / sync
```

## Примітки
- Модель за замовчуванням — `claude-opus-4-8` (adaptive thinking увімкнено для чату).
- `store.py` тримає дані в пам'яті — зникають при перезапуску. На Фазі 2 замінимо на SQLite/Postgres.
- Калорії по фото повертаються як структурований JSON (`FoodAnalysis`) через structured outputs.
