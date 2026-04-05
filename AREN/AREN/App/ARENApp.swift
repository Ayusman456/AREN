import SwiftData
import SwiftUI

@main
struct ARENApp: App {
    @StateObject private var authService = AuthService()

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
            Group {
                if authService.isLaunching {
                    SplashView()
                } else {
                    AppShellView()
                }
            }
            .task {
                await authService.prepareSessionIfNeeded()
            }
            .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
