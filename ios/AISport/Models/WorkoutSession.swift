import Foundation
import SwiftData

/// Записане тренування. Зберігається локально через SwiftData.
@Model
final class WorkoutSession {
    var id: UUID
    var activityTypeRaw: String
    var startDate: Date
    var endDate: Date

    /// Дистанція у метрах.
    var distanceMeters: Double
    /// Кроки за тренування.
    var steps: Int
    /// Спалені калорії (активна енергія, ккал).
    var activeCalories: Double
    /// Середній пульс, уд/хв.
    var averageHeartRate: Double
    /// Максимальний пульс, уд/хв.
    var maxHeartRate: Double

    @Relationship(deleteRule: .cascade, inverse: \RoutePoint.session)
    var route: [RoutePoint]

    @Relationship(deleteRule: .cascade, inverse: \HeartRateSample.session)
    var heartRateSamples: [HeartRateSample]

    init(
        id: UUID = UUID(),
        activityType: ActivityType,
        startDate: Date,
        endDate: Date,
        distanceMeters: Double = 0,
        steps: Int = 0,
        activeCalories: Double = 0,
        averageHeartRate: Double = 0,
        maxHeartRate: Double = 0
    ) {
        self.id = id
        self.activityTypeRaw = activityType.rawValue
        self.startDate = startDate
        self.endDate = endDate
        self.distanceMeters = distanceMeters
        self.steps = steps
        self.activeCalories = activeCalories
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.route = []
        self.heartRateSamples = []
    }

    var activityType: ActivityType {
        ActivityType(rawValue: activityTypeRaw) ?? .running
    }

    var duration: TimeInterval { endDate.timeIntervalSince(startDate) }

    /// Середній темп, секунд на кілометр (0, якщо дистанції нема).
    var paceSecondsPerKm: Double {
        guard distanceMeters > 0 else { return 0 }
        return duration / (distanceMeters / 1000.0)
    }
}
