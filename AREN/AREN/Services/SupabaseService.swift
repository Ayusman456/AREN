import Foundation
#if canImport(Supabase)
import Supabase
#endif

final class SupabaseService {
    static let shared = SupabaseService()

    private init() {}

    func ensureAnonymousSession() async throws -> Bool {
        #if canImport(Supabase)
        guard let client = try? SupabaseClientFactory.makeClient() else {
            return false
        }

        if client.auth.currentSession != nil {
            return true
        }

        _ = try await client.auth.signInAnonymously()
        return true
        #else
        return false
        #endif
    }
}
