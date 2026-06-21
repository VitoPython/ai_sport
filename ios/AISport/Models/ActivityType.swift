import Foundation
import HealthKit

/// Тип активності. Поки що біг і ходьба — основа Фази 1.
enum ActivityType: String, Codable, CaseIterable, Identifiable {
    case running
    case walking

    var id: String { rawValue }

    var title: String {
        switch self {
        case .running: return "Біг"
        case .walking: return "Ходьба"
        }
    }

    var systemImage: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        }
    }

    /// Відповідник у HealthKit для збереження тренування.
    var hkActivityType: HKWorkoutActivityType {
        switch self {
        case .running: return .running
        case .walking: return .walking
        }
    }
}
