import Foundation
import SwiftData

@Model
final class Outfit {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date

    var user: AppUser?

    @Relationship(deleteRule: .cascade, inverse: \OutfitItem.outfit)
    var items: [OutfitItem]

    @Relationship(deleteRule: .nullify, inverse: \OutfitHistory.outfit)
    var history: [OutfitHistory]

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        user: AppUser? = nil
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.user = user
        self.items = []
        self.history = []
    }
}
