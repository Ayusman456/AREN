import SwiftData
import SwiftUI

@main
struct ARENApp: App {
    private let sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainer(
                for: ARENDataModel.schema,
                configurations: [ARENDataModel.modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
