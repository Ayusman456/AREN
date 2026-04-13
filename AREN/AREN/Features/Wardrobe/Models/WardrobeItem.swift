import Foundation

struct WardrobeItem: Identifiable, Decodable {
    let id: UUID
    let category: String?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case imageURL = "processed_image_url"
    }

    // Derived — used in UI
    var name: String { category?.uppercased() ?? "ITEM" }
    var isProcessing: Bool { imageURL == nil }
}
