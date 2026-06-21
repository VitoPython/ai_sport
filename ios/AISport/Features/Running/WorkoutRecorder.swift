import Foundation
import SwiftData
import CoreLocation

/// Стан запису тренування: оркеструє Location + Motion + HealthKit, агрегує метрики
/// й зберігає завершену сесію у SwiftData.
@Observable
final class WorkoutRecorder {
    enum State { case idle, running, paused }

    private(set) var state: State = .idle
    var activityType: ActivityType = .running

    // Живі метрики для UI.
    private(set) var elapsed: TimeInterval = 0
    private(set) var distanceMeters: Double = 0
    private(set) var steps: Int = 0
    private(set) var currentHeartRate: Double = 0

    private let location = LocationService()
    private let motion = MotionService()
    private let health = HealthKitService()

    private var startDate: Date?
    private var accumulatedTime: TimeInterval = 0
    private var timer: Timer?
    private var heartRates: [HeartRateSample] = []

    /// Поточний темп, секунд/км.
    var paceSecondsPerKm: Double {
        guard distanceMeters > 0 else { return 0 }
        return elapsed / (distanceMeters / 1000.0)
    }

    /// Груба оцінка спалених калорій (уточнюється з HealthKit при збереженні).
    var estimatedCalories: Double {
        // ~0.9 ккал/кг/км для бігу; беремо умовні 70 кг як заглушку до профілю користувача.
        let weightKg = 70.0
        let km = distanceMeters / 1000.0
        let factor = activityType == .running ? 0.9 : 0.5
        return weightKg * km * factor
    }

    // MARK: - Дозволи

    func requestPermissions() {
        location.requestAuthorization()
        Task { await health.requestAuthorization() }
    }

    // MARK: - Керування сесією

    func start() {
        guard state == .idle else { return }
        startDate = Date()
        accumulatedTime = 0
        distanceMeters = 0
        steps = 0
        heartRates.removeAll()
        state = .running

        location.startTracking()
        motion.startCounting()
        health.startHeartRateUpdates { [weak self] bpm, date in
            guard let self else { return }
            self.currentHeartRate = bpm
            self.heartRates.append(HeartRateSample(timestamp: date, bpm: bpm))
        }
        startTimer()
    }

    func pause() {
        guard state == .running else { return }
        state = .paused
        accumulatedTime = elapsed
        timer?.invalidate()
        location.pauseTracking()
    }

    func resume() {
        guard state == .paused else { return }
        startDate = Date()
        state = .running
        location.resumeTracking()
        startTimer()
    }

    /// Завершує сесію, зберігає у SwiftData та (за згодою) у Health.
    func stop(context: ModelContext) {
        guard state != .idle else { return }
        timer?.invalidate()
        let end = Date()
        let begin = end.addingTimeInterval(-elapsed)

        location.stopTracking()
        motion.stopCounting()
        health.stopHeartRateUpdates()

        let avgHR = heartRates.isEmpty ? 0 : heartRates.map(\.bpm).reduce(0, +) / Double(heartRates.count)
        let maxHR = heartRates.map(\.bpm).max() ?? 0

        let session = WorkoutSession(
            activityType: activityType,
            startDate: begin,
            endDate: end,
            distanceMeters: distanceMeters,
            steps: steps,
            activeCalories: estimatedCalories,
            averageHeartRate: avgHR,
            maxHeartRate: maxHR
        )
        session.route = location.locations.map { RoutePoint(from: $0) }
        session.heartRateSamples = heartRates

        context.insert(session)
        try? context.save()

        Task { await health.saveWorkout(session) }

        reset()
    }

    private func reset() {
        state = .idle
        elapsed = 0
        distanceMeters = 0
        steps = 0
        currentHeartRate = 0
        accumulatedTime = 0
        startDate = nil
    }

    // MARK: - Таймер / синхронізація метрик

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self, let startDate else { return }
            self.elapsed = self.accumulatedTime + Date().timeIntervalSince(startDate)
            self.distanceMeters = self.location.distanceMeters
            self.steps = self.motion.steps
        }
    }
}
