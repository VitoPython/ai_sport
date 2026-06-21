import Foundation
import HealthKit

/// Доступ до HealthKit: дозволи, живий пульс, активна енергія, збереження тренування.
@Observable
final class HealthKitService {
    private let store = HKHealthStore()

    private(set) var latestHeartRate: Double = 0
    private(set) var isAuthorized = false

    private var heartRateQuery: HKAnchoredObjectQuery?

    /// Типи, які читаємо/пишемо.
    private var readTypes: Set<HKObjectType> {
        [
            HKQuantityType(.heartRate),
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            .workoutType(),
        ]
    }

    private var shareTypes: Set<HKSampleType> {
        [
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            .workoutType(),
        ]
    }

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        do {
            try await store.requestAuthorization(toShare: shareTypes, read: readTypes)
            isAuthorized = true
        } catch {
            print("HealthKit authorization error: \(error)")
        }
    }

    // MARK: - Живий пульс

    /// Підписка на нові заміри пульсу. `onSample` викликається для кожного нового значення.
    func startHeartRateUpdates(onSample: @escaping (Double, Date) -> Void) {
        let hrType = HKQuantityType(.heartRate)
        let unit = HKUnit.count().unitDivided(by: .minute())

        let handler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { [weak self] _, samples, _, _, _ in
            guard let self, let samples = samples as? [HKQuantitySample] else { return }
            for sample in samples {
                let bpm = sample.quantity.doubleValue(for: unit)
                DispatchQueue.main.async {
                    self.latestHeartRate = bpm
                    onSample(bpm, sample.endDate)
                }
            }
        }

        let query = HKAnchoredObjectQuery(
            type: hrType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit,
            resultsHandler: handler
        )
        query.updateHandler = handler
        store.execute(query)
        heartRateQuery = query
    }

    func stopHeartRateUpdates() {
        if let query = heartRateQuery {
            store.stop(query)
            heartRateQuery = nil
        }
    }

    // MARK: - Збереження тренування

    /// Зберігає завершене тренування у Health як HKWorkout.
    func saveWorkout(_ session: WorkoutSession) async {
        let energy = HKQuantity(unit: .kilocalorie(), doubleValue: session.activeCalories)
        let distance = HKQuantity(unit: .meter(), doubleValue: session.distanceMeters)

        let workout = HKWorkout(
            activityType: session.activityType.hkActivityType,
            start: session.startDate,
            end: session.endDate,
            duration: session.duration,
            totalEnergyBurned: energy,
            totalDistance: distance,
            metadata: nil
        )

        do {
            try await store.save(workout)
        } catch {
            print("Не вдалося зберегти тренування у Health: \(error)")
        }
    }
}
