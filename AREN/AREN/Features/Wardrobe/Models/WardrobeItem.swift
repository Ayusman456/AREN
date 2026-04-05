import Foundation

struct WardrobeItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var category: String
    var productCode: String
    var colorNote: String
    var imageAssetName: String
    var priceText: String?
    var colourSwatchHex: String?
    var showsAddButton: Bool

    init(
        title: String,
        category: String,
        productCode: String,
        colorNote: String,
        imageAssetName: String = "Wardrobe/tops_001",
        priceText: String? = nil,
        colourSwatchHex: String? = nil,
        showsAddButton: Bool = true
    ) {
        self.title = title
        self.category = category
        self.productCode = productCode
        self.colorNote = colorNote
        self.imageAssetName = imageAssetName
        self.priceText = priceText
        self.colourSwatchHex = colourSwatchHex
        self.showsAddButton = showsAddButton
    }
}
