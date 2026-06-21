import Foundation
import CoreMotion

/// Рахує кроки та каденс у реальному часі через CMPedometer.
@Observable
final class MotionService {
    private let pedometer = CMPedometer()

    private(set) var steps: Int = 0
    /// Каденс — кроків за хвилину (якщо доступно).
    private(set) var cadence: Double = 0
    private(set) var isAvailable: Bool = CMPedometer.isStepCountingAvailable()

    func startCounting(from date: Date = Date()) {
        guard CMPedometer.isStepCountingAvailable() else { return }
        steps = 0
        cadence = 0
        pedometer.startUpdates(from: date) { [weak self] data, error in
            guard let self, let data, error == nil else { return }
            DispatchQueue.main.async {
                self.steps = data.numberOfSteps.intValue
                if let pace = data.currentCadence {
                    // currentCadence у кроках/сек → кроків/хв
                    self.cadence = pace.doubleValue * 60
                }
            }
        }
    }

    func stopCounting() {
        pedometer.stopUpdates()
    }
}
