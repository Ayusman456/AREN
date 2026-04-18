import Foundation
#if canImport(Supabase)
import Supabase
#endif

struct SupabaseConfiguration: Sendable {
    let url: URL
    let anonKey: String

    static func load(bundle: Bundle = .main) throws -> SupabaseConfiguration {
        let plistValues = loadPlistValues(bundle: bundle)
        let environmentValues = ProcessInfo.processInfo.environment

        let urlString = plistValues["SUPABASE_URL"] ?? environmentValues["SUPABASE_URL"]
        let anonKey = plistValues["SUPABASE_ANON_KEY"] ?? environmentValues["SUPABASE_ANON_KEY"]

        guard let urlString, !urlString.isEmpty else {
            throw SupabaseConfigurationError.missingValue("SUPABASE_URL")
        }

        guard let anonKey, !anonKey.isEmpty else {
            throw SupabaseConfigurationError.missingValue("SUPABASE_ANON_KEY")
        }

        guard let url = URL(string: urlString) else {
            throw SupabaseConfigurationError.invalidURL(urlString)
        }

        return SupabaseConfiguration(url: url, anonKey: anonKey)
    }

    private static func loadPlistValues(bundle: Bundle) -> [String: String] {
        guard let url = bundle.url(forResource: "SupabaseConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil),
              let values = plist as? [String: String] else {
            return [:]
        }

        return values
    }
}

enum SupabaseConfigurationError: LocalizedError {
    case missingValue(String)
    case invalidURL(String)

    var errorDescription: String? {
        switch self {
        case let .missingValue(key):
            return "Missing Supabase configuration value for \(key). Add SupabaseConfig.plist locally or provide the environment variable."
        case let .invalidURL(value):
            return "Supabase URL is invalid: \(value)"
        }
    }
}
#if canImport(Supabase)
enum SupabaseClientFactory {
    static func makeClient(bundle: Bundle = .main) throws -> SupabaseClient {
        let configuration = try SupabaseConfiguration.load(bundle: bundle)

        return SupabaseClient(
            supabaseURL: configuration.url,
            supabaseKey: configuration.anonKey,
            options: SupabaseClientOptions(
                auth: .init(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
#endif
