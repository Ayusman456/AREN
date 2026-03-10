import Foundation
import SwiftData

@Model
final class StyleBoardItem {
    @Attribute(.unique) var id: UUID
    var sourceURL: URL?
    var price: Double?
    var retailer: String?
    var status: StyleBoardItemStatus
    var positionX: Double
    var positionY: Double
    var scale: Double
    var layer: Int

    var board: StyleBoard?
    var clothingItem: ClothingItem?

    init(
        id: UUID = UUID(),
        sourceURL: URL? = nil,
        price: Double? = nil,
        retailer: String? = nil,
        status: StyleBoardItemStatus = .saved,
        positionX: Double = 0,
        positionY: Double = 0,
        scale: Double = 1,
        layer: Int = 0,
        board: StyleBoard? = nil,
        clothingItem: ClothingItem? = nil
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.price = price
        self.retailer = retailer
        self.status = status
        self.positionX = positionX
        self.positionY = positionY
        self.scale = scale
        self.layer = layer
        self.board = board
        self.clothingItem = clothingItem
    }
}
