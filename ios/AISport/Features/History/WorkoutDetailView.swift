import SwiftUI
import SwiftData
import MapKit

/// Деталі одного тренування: метрики + карта маршруту.
struct WorkoutDetailView: View {
    let session: WorkoutSession

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !session.route.isEmpty {
                    routeMap
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    stat("Дистанція", Metric.distance(session.distanceMeters), "ruler")
                    stat("Час", Metric.duration(session.duration), "clock")
                    stat("Темп", Metric.pace(session.paceSecondsPerKm), "speedometer")
                    stat("Кроки", "\(session.steps)", "figure.walk")
                    stat("Сер. пульс", Metric.heartRate(session.averageHeartRate), "heart.fill")
                    stat("Макс. пульс", Metric.heartRate(session.maxHeartRate), "heart.circle")
                    stat("Калорії", Metric.calories(session.activeCalories), "flame.fill")
                }
            }
            .padding()
        }
        .navigationTitle(session.activityType.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var routeMap: some View {
        Map {
            MapPolyline(coordinates: session.route
                .sorted { $0.timestamp < $1.timestamp }
                .map(\.coordinate))
                .stroke(.blue, lineWidth: 4)
        }
    }

    private func stat(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(.secondary)
            Text(value).font(.title3).fontWeight(.semibold).monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}
