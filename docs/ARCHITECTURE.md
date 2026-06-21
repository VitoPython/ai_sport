# Архітектура

## Огляд

```
┌──────────────────────────────────┐        ┌────────────────────────────────┐
│  iOS app  (Swift / SwiftUI)      │        │   Backend  (Python / FastAPI)  │
│                                  │        │                                │
│  Features/                       │        │   /chat   ── Claude (tool use) │
│   └ Running (трекер, історія)    │  HTTPS │   /vision ── food → калорії/БЖВ │
│  Health/                         │◄──────►│   /sync   ── тренування, профіль│
│   └ HealthKit, Motion, Location  │  JSON  │                                │
│  Models/  (Workout, Sample…)     │        │   Claude API ──────────────────│
│  Storage/ (SwiftData) on-device  │        │   tools: get_workouts,         │
│                                  │        │          get_profile, nutrition│
└──────────────────────────────────┘        └────────────────────────────────┘
        │                                              │
   Apple Watch (Фаза 4)                          БД (SQLite→Postgres)
```

## iOS-клієнт

- **SwiftUI** для UI, MVVM (View + ViewModel/`@Observable`).
- **HealthKitService** — дозволи, читання пульсу/кроків/енергії, запис тренувань як `HKWorkout`.
- **LocationService** — `CLLocationManager`, GPS-трек, дистанція, темп.
- **MotionService** — `CMPedometer` для кроків у реальному часі.
- **WorkoutRecorder** — оркеструє сесію тренування, агрегує метрики, зберігає у SwiftData.
- **Storage (SwiftData)** — локальні моделі `WorkoutSession`, `RoutePoint`, `HeartRateSample`.

Дані здоров'я лишаються на пристрої. На бекенд відправляється лише знеособлений/потрібний
контекст для AI-асистента (за згодою користувача).

## Бекенд

- **FastAPI**, async.
- `/chat` — проксі до Claude з **tool use**. Claude викликає інструменти, бекенд виконує їх
  (читання тренувань/профілю/харчування з БД) і повертає результат у модель.
- `/vision` — приймає фото страви, надсилає у Claude (multimodal) → структурований JSON калорій і БЖВ.
- `/sync` — синхронізація тренувань і профілю (опційно, для крос-девайс і контексту AI).
- БД: на старті SQLite, далі Postgres.
- Секрети через `.env` (`ANTHROPIC_API_KEY`).

## Моделі Claude
- Діалоги/планування: `claude-opus-4-8` (якість) або `claude-sonnet-4-6` (швидше/дешевше).
- Vision (фото їжі): той самий multimodal-ендпоінт.

## Потоки даних (приклади)

**Запис забігу:** `RunningView` → `WorkoutRecorder` → (Location+Motion+HealthKit) → SwiftData → Історія.

**Питання асистенту:** `ChatView` → `/chat` → Claude вирішує викликати `get_workouts` → бекенд читає БД
→ повертає Claude → Claude формує відповідь/план → клієнт.

**Калорії по фото:** `FoodPhotoView` → `/vision` → Claude (фото) → `{calories, protein, fat, carbs, items[]}`.
