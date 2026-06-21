# iOS-застосунок (AISport)

Нативний застосунок на Swift/SwiftUI. **Збирається тільки на Mac в Xcode.**

## Як зібрати на Mac

Цей каталог містить готові Swift-файли. Щоб отримати робочий застосунок:

1. Перенеси репозиторій на Mac (`git clone` / `git pull`).
2. У Xcode: **File → New → Project → iOS → App**
   - Product Name: `AISport`
   - Interface: **SwiftUI**, Language: **Swift**
   - Storage: **SwiftData** (можна не вмикати — модель уже описана в коді)
3. Видали згенеровані `*App.swift` і `ContentView.swift`, перетягни сюди файли з `AISport/`
   (Add Files to "AISport"…, з опцією *Copy items if needed*).
4. Додай у **Info.plist** ключі дозволів (див. `AISport/Info-keys.md`).
5. Увімкни **Capabilities → HealthKit** (Signing & Capabilities).
6. Обери ціль — свій iPhone — і запусти ▶︎.

> Альтернатива: можна тримати проєкт як Swift Package + XcodeGen/Tuist, але для старту найпростіше
> створити App-проєкт у Xcode і додати ці файли.

## Структура

```
AISport/
├─ App/        AISportApp.swift           — точка входу, налаштування SwiftData
├─ Models/     ActivityType, WorkoutSession, RoutePoint, HeartRateSample
├─ Health/     LocationService, MotionService, HealthKitService
├─ Features/
│  ├─ Running/ WorkoutRecorder (стан сесії), RunningView
│  └─ History/ HistoryView, WorkoutDetailView
├─ Support/    Formatters
└─ Info-keys.md   — які ключі додати в Info.plist
```

## Що далі
Після Фази 1 додамо `ChatView` (AI-асистент) і `FoodPhotoView` (калорії по фото) — вони
ходитимуть у бекенд (`../backend`).
