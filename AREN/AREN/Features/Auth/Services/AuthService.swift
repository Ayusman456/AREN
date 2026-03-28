import Combine
import Foundation

@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var isLaunching = true
    @Published private(set) var sessionTitle = "Preparing session"
    @Published private(set) var sessionMessage = "Starting anonymous mode"

    private var hasPreparedSession = false

    func prepareSessionIfNeeded() async {
        guard !hasPreparedSession else { return }
        hasPreparedSession = true

        let launchStart = Date()

        do {
            let signedIn = try await SupabaseService.shared.ensureAnonymousSession()
            if signedIn {
                sessionTitle = "Anonymous session active"
                sessionMessage = "You can explore the V2 shell before linking Apple or Google."
            } else {
                sessionTitle = "Demo mode"
                sessionMessage = "Supabase is unavailable, so the app is running on local demo data."
            }
        } catch {
            sessionTitle = "Demo mode"
            sessionMessage = error.localizedDescription
        }

        let elapsed = Date().timeIntervalSince(launchStart)
        let minimumSplashDuration = 1.5

        if elapsed < minimumSplashDuration {
            try? await Task.sleep(for: .seconds(minimumSplashDuration - elapsed))
        }

        isLaunching = false
    }
}
