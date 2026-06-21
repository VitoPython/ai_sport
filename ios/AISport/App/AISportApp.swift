import SwiftUI
import SwiftData

@main
struct AISportApp: App {
    /// Спільний контейнер SwiftData для всіх локальних моделей здоров'я/тренувань.
    let container: ModelContainer = {
        let schema = Schema([
            WorkoutSession.self,
            RoutePoint.self,
            HeartRateSample.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Не вдалося створити ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}

/// Кореневий екран із вкладками.
struct RootView: View {
    var body: some View {
        TabView {
            RunningView()
                .tabItem { Label("Тренування", systemImage: "figure.run") }

            HistoryView()
                .tabItem { Label("Історія", systemImage: "list.bullet.rectangle") }

            ChatView()
                .tabItem { Label("Асистент", systemImage: "bubble.left.and.bubble.right") }

            FoodView()
                .tabItem { Label("Харчування", systemImage: "fork.knife") }
        }
    }
}
