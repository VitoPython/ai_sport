import Foundation
import SwiftData

/// Один замір пульсу під час тренування.
@Model
final class HeartRateSample {
    var timestamp: Date
    /// Удари за хвилину.
    var bpm: Double

    var session: WorkoutSession?

    init(timestamp: Date, bpm: Double) {
        self.timestamp = timestamp
        self.bpm = bpm
    }
}
