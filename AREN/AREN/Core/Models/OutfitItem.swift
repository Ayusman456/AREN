import Foundation
import SwiftData

@Model
final class OutfitItem {
    @Attribute(.unique) var id: UUID
    var positionX: Double
    var positionY: Double
    var scale: Double
    var rotation: Double
    var layer: Int

    var outfit: Outfit?
    var clothingItem: ClothingItem?

    init(
        id: UUID = UUID(),
        positionX: Double = 0,
        positionY: Double = 0,
        scale: Double = 1,
        rotation: Double = 0,
        layer: Int = 0,
        outfit: Outfit? = nil,
        clothingItem: ClothingItem? = nil
    ) {
        self.id = id
        self.positionX = positionX
        self.positionY = positionY
        self.scale = scale
        self.rotation = rotation
        self.layer = layer
        self.outfit = outfit
        self.clothingItem = clothingItem
    }
}
