import SwiftUI
import SwiftData

/// Список збережених тренувань.
struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutSession.startDate, order: .reverse)
    private var sessions: [WorkoutSession]

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "Поки немає тренувань",
                        systemImage: "figure.run",
                        description: Text("Запиши перший забіг на вкладці «Тренування».")
                    )
                } else {
                    List {
                        ForEach(sessions) { session in
                            NavigationLink {
                                WorkoutDetailView(session: session)
                            } label: {
                                WorkoutRow(session: session)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Історія")
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets { context.delete(sessions[index]) }
        try? context.save()
    }
}

private struct WorkoutRow: View {
    let session: WorkoutSession

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: session.activityType.systemImage)
                .font(.title2)
                .frame(width: 40)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 4) {
                Text(session.activityType.title).font(.headline)
                Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(Metric.distance(session.distanceMeters)).font(.subheadline).fontWeight(.semibold)
                Text(Metric.duration(session.duration)).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
