import Foundation

/// Спільні форматери метрик для UI.
enum Metric {
    /// Тривалість → "1:23:45" або "12:34".
    static func duration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }

    /// Дистанція у метрах → "5.42 км" або "850 м".
    static func distance(_ meters: Double) -> String {
        meters >= 1000
            ? String(format: "%.2f км", meters / 1000)
            : String(format: "%.0f м", meters)
    }

    /// Темп (сек/км) → "5:30 /км".
    static func pace(_ secondsPerKm: Double) -> String {
        guard secondsPerKm > 0, secondsPerKm.isFinite else { return "—" }
        let m = Int(secondsPerKm) / 60
        let s = Int(secondsPerKm) % 60
        return String(format: "%d:%02d /км", m, s)
    }

    static func heartRate(_ bpm: Double) -> String {
        bpm > 0 ? "\(Int(bpm)) уд/хв" : "—"
    }

    static func calories(_ kcal: Double) -> String {
        String(format: "%.0f ккал", kcal)
    }
}
