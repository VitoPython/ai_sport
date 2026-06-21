import Foundation
import CoreLocation

/// Веде GPS-трек під час тренування: видає точки, рахує сумарну дистанцію.
@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    /// Накопичений трек поточної сесії.
    private(set) var locations: [CLLocation] = []
    /// Сумарна дистанція у метрах.
    private(set) var distanceMeters: Double = 0
    /// Поточна швидкість, м/с.
    private(set) var currentSpeed: Double = 0
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private var isTracking = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .fitness
        manager.distanceFilter = 5 // метрів
        authorizationStatus = manager.authorizationStatus
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        locations.removeAll()
        distanceMeters = 0
        currentSpeed = 0
        isTracking = true
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }

    func pauseTracking() {
        isTracking = false
        manager.stopUpdatingLocation()
    }

    func resumeTracking() {
        isTracking = true
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        isTracking = false
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        guard isTracking else { return }
        for location in newLocations {
            // Відсіюємо неточні та застарілі заміри.
            guard location.horizontalAccuracy >= 0, location.horizontalAccuracy < 30 else { continue }
            if let last = locations.last {
                let delta = location.distance(from: last)
                // Ігноруємо мікро-дрейф на місці.
                if delta > 1 { distanceMeters += delta }
            }
            locations.append(location)
            currentSpeed = max(0, location.speed)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
