import Foundation
import SwiftData

@Model
final class StyleBoard {
    @Attribute(.unique) var id: UUID
    var title: String
    var coverImageURL: URL?
    var isPublic: Bool
    var createdAt: Date

    var user: AppUser?

    @Relationship(deleteRule: .cascade, inverse: \StyleBoardItem.board)
    var items: [StyleBoardItem]

    init(
        id: UUID = UUID(),
        title: String,
        coverImageURL: URL? = nil,
        isPublic: Bool = false,
        createdAt: Date = .now,
        user: AppUser? = nil
    ) {
        self.id = id
        self.title = title
        self.coverImageURL = coverImageURL
        self.isPublic = isPublic
        self.createdAt = createdAt
        self.user = user
        self.items = []
    }
}
