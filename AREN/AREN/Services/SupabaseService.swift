import Foundation
import Supabase
import UIKit

// MARK: - SupabaseService
// Singleton. Owns the SupabaseClient instance.
// Handles: anonymous auth, image upload, clothing_items insert.

@MainActor
final class SupabaseService {

    static let shared = SupabaseService()

    let client: SupabaseClient
    private let configuration: SupabaseConfiguration

    private init() {
        do {
            let config = try SupabaseConfiguration.load()
            self.configuration = config
            client = try SupabaseClientFactory.makeClient()
        } catch {
            fatalError("Supabase client failed to initialise: \(error.localizedDescription)")
        }
    }

    var anonKey: String {
        configuration.anonKey
    }

    // MARK: - Auth

    func ensureAnonymousSession() async throws -> Bool {
        do {
            let session = try await client.auth.session
            print("Session restored — user: \(session.user.id)")
            return true
        } catch {
            do {
                let response = try await client.auth.signInAnonymously()
                print("Anonymous session created — user: \(response.user.id)")
                return true
            } catch {
                print("Anonymous sign-in failed: \(error)")
                return false
            }
        }
    }

    func currentUserID() async -> UUID? {
        do {
            let session = try await client.auth.session
            return session.user.id
        } catch {
            print("No active session: \(error)")
            return nil
        }
    }

    // MARK: - Storage

    func uploadClothingImage(_ image: UIImage, itemID: UUID) async throws -> String {
        guard let pngData = image.pngData() else {
            throw SupabaseServiceError.imageEncodingFailed
        }

        let filePath = "\(itemID.uuidString).png"

        try await client.storage
            .from("clothing-images")
            .upload(
                filePath,
                data: pngData,
                options: FileOptions(contentType: "image/png")
            )

        let publicURL = try client.storage
            .from("clothing-images")
            .getPublicURL(path: filePath)

        return publicURL.absoluteString
    }

    // MARK: - Database

    func insertClothingItem(
        userID: UUID,
        processedImageURL: String,
        category: String? = nil
    ) async throws -> UUID {
        let itemID = UUID()

        let payload = ClothingItemInsert(
            id: itemID,
            userID: userID,
            processedImageURL: processedImageURL,
            category: category,
            processingStatus: "ready"
        )

        try await client
            .from("clothing_items")
            .insert(payload)
            .execute()

        return itemID
    }
}

// MARK: - Insert Payload

private struct ClothingItemInsert: Encodable {
    let id: UUID
    let userID: UUID
    let processedImageURL: String
    let category: String?
    let processingStatus: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID            = "user_id"
        case processedImageURL = "processed_image_url"
        case category
        case processingStatus  = "processing_status"
    }
}

// MARK: - Errors

enum SupabaseServiceError: LocalizedError {
    case imageEncodingFailed
    case noActiveSession

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed: return "Failed to encode image as PNG."
        case .noActiveSession:     return "No active Supabase session."
        }
    }
}
