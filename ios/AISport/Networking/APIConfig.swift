import Foundation

/// Налаштування доступу до бекенду.
enum APIConfig {
    /// Базовий URL бекенду. Заміни на свій домен Dokploy (або локальний для симулятора).
    /// УВАГА: для iOS потрібен валідний HTTPS-сертифікат (ATS). Тимчасовий traefik.me
    /// може не пройти — для реального пристрою підключи власний домен.
    static let baseURL = URL(string: "https://aisport-backend-79b1d1-ff78bb-62-238-31-109.traefik.me")!

    /// Стабільний ідентифікатор користувача (поки локальний, один на пристрій).
    /// Усі дані на бекенді (тренування, профіль, чат-контекст) прив'язані до нього.
    static var userID: String {
        let key = "ai_sport_user_id"
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: key)
        return new
    }
}
