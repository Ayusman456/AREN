import Foundation
import SwiftData

@Model
final class ClothingItem {
    @Attribute(.unique) var id: UUID
    var imageURL: URL?
    var processedImageURL: URL?
    var category: String
    var tagsStorage: String
    var color: String?
    var brand: String?
    var styleMode: WardrobeMode
    var occasion: ClothingOccasion?
    var fabric: String?
    var aiConfidence: Double
    var isAvailable: Bool
    var wearCount: Int
    var lastWornAt: Date?
    var createdAt: Date

    var user: AppUser?

    @Relationship(deleteRule: .cascade, inverse: \OutfitItem.clothingItem)
    var outfitItems: [OutfitItem]

    @Relationship(deleteRule: .nullify, inverse: \StyleBoardItem.clothingItem)
    var styleBoardItems: [StyleBoardItem]

    var tags: [String] {
        get {
            tagsStorage
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        set {
            tagsStorage = newValue.joined(separator: ",")
        }
    }

    init(
        id: UUID = UUID(),
        imageURL: URL? = nil,
        processedImageURL: URL? = nil,
        category: String,
        tags: [String] = [],
        color: String? = nil,
        brand: String? = nil,
        styleMode: WardrobeMode = .both,
        occasion: ClothingOccasion? = nil,
        fabric: String? = nil,
        aiConfidence: Double = 0,
        isAvailable: Bool = true,
        wearCount: Int = 0,
        lastWornAt: Date? = nil,
        createdAt: Date = .now,
        user: AppUser? = nil
    ) {
        self.id = id
        self.imageURL = imageURL
        self.processedImageURL = processedImageURL
        self.category = category
        self.tagsStorage = tags.joined(separator: ",")
        self.color = color
        self.brand = brand
        self.styleMode = styleMode
        self.occasion = occasion
        self.fabric = fabric
        self.aiConfidence = aiConfidence
        self.isAvailable = isAvailable
        self.wearCount = wearCount
        self.lastWornAt = lastWornAt
        self.createdAt = createdAt
        self.user = user
        self.outfitItems = []
        self.styleBoardItems = []
    }
}
