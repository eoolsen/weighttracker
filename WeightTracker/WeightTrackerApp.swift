import SwiftUI
import SwiftData

@main
struct WeightTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [WeightEntry.self, UserSettings.self])
    }
}
