# Ключі дозволів для Info.plist

Додай ці ключі (Xcode → target → Info, або правка Info.plist):

| Ключ | Значення (рядок для користувача) |
|---|---|
| `NSHealthShareUsageDescription` | Застосунку потрібен доступ до даних здоров'я, щоб відстежувати пульс, кроки та енергію під час тренувань. |
| `NSHealthUpdateUsageDescription` | Застосунок зберігає твої тренування у Health. |
| `NSLocationWhenInUseUsageDescription` | Доступ до геолокації потрібен для запису маршруту, дистанції та темпу бігу. |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | Доступ до геолокації у фоні дозволяє продовжувати запис під час бігу із заблокованим екраном. |
| `NSMotionUsageDescription` | Доступ до руху потрібен для підрахунку кроків і каденсу. |

## Capabilities (Signing & Capabilities)
- **HealthKit** — увімкни.
- **Background Modes** → *Location updates* (щоб трек писався у фоні).
