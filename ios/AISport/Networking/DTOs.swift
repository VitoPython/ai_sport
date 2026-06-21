import Foundation

// Моделі передачі даних (DTO), що відповідають JSON бекенду.
// Кодування/декодування використовує snake_case-конвертацію (див. APIClient),
// тож тут — звичний camelCase.

// ───── Чат ─────

struct ChatMessage: Codable {
    let role: String      // "user" | "assistant"
    let content: String
}

struct ChatRequest: Codable {
    let messages: [ChatMessage]
    let userId: String
}

struct ChatResponse: Codable {
    let reply: String
}

// ───── Синхронізація тренувань ─────

struct WorkoutDTO: Codable {
    let id: String
    let activityType: String
    let startDate: String     // ISO 8601
    let endDate: String       // ISO 8601
    let distanceMeters: Double
    let steps: Int
    let activeCalories: Double
    let averageHeartRate: Double
    let maxHeartRate: Double
}

extension WorkoutDTO {
    /// Побудувати DTO зі збереженої сесії тренування.
    init(session: WorkoutSession) {
        let iso = ISO8601DateFormatter()
        self.init(
            id: session.id.uuidString,
            activityType: session.activityType.rawValue,
            startDate: iso.string(from: session.startDate),
            endDate: iso.string(from: session.endDate),
            distanceMeters: session.distanceMeters,
            steps: session.steps,
            activeCalories: session.activeCalories,
            averageHeartRate: session.averageHeartRate,
            maxHeartRate: session.maxHeartRate
        )
    }
}

struct SyncResult: Codable {
    let added: Int
    let total: Int
}

// ───── Профіль ─────

struct Profile: Codable {
    var goal: String?
    var experienceLevel: String?
    var weightKg: Double?
    var heightCm: Double?
    var age: Int?
    var weeklyTargetRuns: Int?
    var notes: String?
}

// ───── Калорії по фото ─────

struct FoodItem: Codable, Identifiable {
    var id = UUID()
    let name: String
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double

    // id — лише для UI, з JSON не читається.
    private enum CodingKeys: String, CodingKey {
        case name, calories, protein, fat, carbs
    }
}

struct FoodAnalysis: Codable {
    let items: [FoodItem]
    let totalCalories: Double
    let totalProtein: Double
    let totalFat: Double
    let totalCarbs: Double
    let notes: String?
}
