import Foundation
import SwiftData

@Model
final class AppUser {
    @Attribute(.unique) var id: UUID
    var email: String
    var username: String?
    var styleMode: WardrobeMode
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ClothingItem.user)
    var clothingItems: [ClothingItem]

    @Relationship(deleteRule: .cascade, inverse: \Outfit.user)
    var outfits: [Outfit]

    @Relationship(deleteRule: .cascade, inverse: \OutfitHistory.user)
    var outfitHistory: [OutfitHistory]

    @Relationship(deleteRule: .cascade, inverse: \StyleBoard.user)
    var styleBoards: [StyleBoard]

    init(
        id: UUID = UUID(),
        email: String,
        username: String? = nil,
        styleMode: WardrobeMode = .both,
        createdAt: Date = .now
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.styleMode = styleMode
        self.createdAt = createdAt
        self.clothingItems = []
        self.outfits = []
        self.outfitHistory = []
        self.styleBoards = []
    }
}
