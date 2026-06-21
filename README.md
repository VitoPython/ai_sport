# AI Sport Assistant 🏃‍♂️🤖

Повноцінний AI спортивний асистент для iOS. Біг та ходьба з відстеженням пульсу, кроків і GPS;
комп'ютерний зір для підрахунку калорій по фото страви; AI-асистент на базі **Claude**, який
складає програми тренувань, відстежує здоров'я та відповідає на питання про харчування.

## Структура репозиторію

```
ai_sport/
├─ ios/        # Нативний застосунок Swift/SwiftUI (збирається в Xcode на Mac)
├─ backend/    # FastAPI: інтеграція з Claude (tool use), food vision, синхронізація
├─ docs/       # План, архітектура, дорожня карта
└─ README.md
```

## Технологічний стек

| Шар | Технологія |
|---|---|
| iOS-клієнт | Swift, SwiftUI, HealthKit, CoreMotion, CoreLocation, SwiftData |
| Apple Watch | watchOS (Фаза 4) |
| Бекенд | Python, FastAPI |
| AI | Claude API (tool use + vision) — модель `claude-opus-4-8` / `claude-sonnet-4-6` |

## Швидкий старт

### Бекенд (Windows / будь-яка ОС)
```bash
cd backend
python -m venv .venv
.venv\Scripts\activate        # Windows
pip install -r requirements.txt
cp .env.example .env          # додай ANTHROPIC_API_KEY
uvicorn app.main:app --reload
```

### iOS (на Mac)
Див. [ios/README.md](ios/README.md) — як зібрати Swift-файли в Xcode-проєкт.

## Документація

- [docs/PLAN.md](docs/PLAN.md) — продуктовий план і фічі
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — архітектура системи
- [docs/ROADMAP.md](docs/ROADMAP.md) — дорожня карта по фазах

## Статус

🚧 **Фаза 1 — Біговий трекер** (у роботі)
