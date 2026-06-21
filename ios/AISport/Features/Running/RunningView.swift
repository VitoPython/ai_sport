import SwiftUI
import SwiftData

/// Головний екран тренування: вибір активності, живі метрики, керування сесією.
struct RunningView: View {
    @Environment(\.modelContext) private var context
    @State private var recorder = WorkoutRecorder()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if recorder.state == .idle {
                    activityPicker
                }

                metricsGrid

                Spacer()

                controls
            }
            .padding()
            .navigationTitle("Тренування")
            .onAppear { recorder.requestPermissions() }
        }
    }

    private var activityPicker: some View {
        Picker("Активність", selection: $recorder.activityType) {
            ForEach(ActivityType.allCases) { type in
                Label(type.title, systemImage: type.systemImage).tag(type)
            }
        }
        .pickerStyle(.segmented)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            MetricCard(title: "Час", value: Metric.duration(recorder.elapsed), icon: "clock")
            MetricCard(title: "Дистанція", value: Metric.distance(recorder.distanceMeters), icon: "ruler")
            MetricCard(title: "Темп", value: Metric.pace(recorder.paceSecondsPerKm), icon: "speedometer")
            MetricCard(title: "Пульс", value: Metric.heartRate(recorder.currentHeartRate), icon: "heart.fill")
            MetricCard(title: "Кроки", value: "\(recorder.steps)", icon: "figure.walk")
            MetricCard(title: "Калорії", value: Metric.calories(recorder.estimatedCalories), icon: "flame.fill")
        }
    }

    @ViewBuilder
    private var controls: some View {
        switch recorder.state {
        case .idle:
            BigButton(title: "Старт", color: .green) { recorder.start() }
        case .running:
            HStack(spacing: 16) {
                BigButton(title: "Пауза", color: .orange) { recorder.pause() }
                BigButton(title: "Стоп", color: .red) { recorder.stop(context: context) }
            }
        case .paused:
            HStack(spacing: 16) {
                BigButton(title: "Продовжити", color: .green) { recorder.resume() }
                BigButton(title: "Стоп", color: .red) { recorder.stop(context: context) }
            }
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title3).foregroundStyle(.secondary)
            Text(value).font(.title2).fontWeight(.semibold).monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct BigButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3).fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .background(color, in: RoundedRectangle(cornerRadius: 16))
        .foregroundStyle(.white)
    }
}

#Preview {
    RunningView()
        .modelContainer(for: [WorkoutSession.self, RoutePoint.self, HeartRateSample.self], inMemory: true)
}
