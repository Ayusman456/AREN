import Foundation

struct WardrobeItem: Identifiable, Decodable {
    let id: UUID
    let category: String?
    let imageURL: String?
    let assetName: String?
    let occasion: String?

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case imageURL = "processed_image_url"
        case occasion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        occasion = try container.decodeIfPresent(String.self, forKey: .occasion)
        assetName = nil // never comes from Supabase
    }

    // Demo fallback init — used by HomeViewModel only
    init(id: UUID, category: String?, imageURL: String?, assetName: String?, occasion: String? = nil) {
        self.id = id
        self.category = category
        self.imageURL = imageURL
        self.assetName = assetName
        self.occasion = occasion
    }

    // MARK: - Derived

    var name: String { category?.uppercased() ?? "ITEM" }
    var isProcessing: Bool { imageURL == nil }
    var brand: String? { nil } // deferred — not yet in Supabase schema

    var garmentSource: GarmentSource? {
        if let urlString = imageURL, let url = URL(string: urlString) {
            return .remote(url)
        }
        if let asset = assetName {
            return .asset(asset)
        }
        return nil
    }
}
