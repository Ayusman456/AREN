import Foundation

struct WardrobeOutfit: Identifiable, Decodable {
    let id: UUID
    let name: String
    let occasion: String?
    let imageURL: String?
    let pieceCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case occasion
        case imageURL = "image_url"
        case pieceCount = "piece_count"
    }
}
