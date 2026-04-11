import Combine
import Foundation

@MainActor
final class WardrobeViewModel: ObservableObject {
    @Published var items: [WardrobeItem] = [
        WardrobeItem(
            title: "Linen Shirt Blue",
            category: "Tops",
            productCode: "",
            colorNote: "Blue",
            imageAssetName: "tops_001"
        ),
        WardrobeItem(
            title: "Dark Shirt",
            category: "Tops",
            productCode: "",
            colorNote: "Brown",
            imageAssetName: "tops_002"
        ),
        WardrobeItem(
            title: "Linen Shorts",
            category: "Bottoms",
            productCode: "",
            colorNote: "Cream",
            imageAssetName: "bottoms_001"
        ),
        WardrobeItem(
            title: "Wide Leg Jeans",
            category: "Bottoms",
            productCode: "",
            colorNote: "Blue",
            imageAssetName: "bottoms_003"
        ),
        WardrobeItem(
            title: "Leather Sandals",
            category: "Shoes",
            productCode: "",
            colorNote: "Dark Brown",
            imageAssetName: "shoes_001"
        ),
    ]
    @Published var outfits: [WardrobeOutfit] = []
    
    func addItem(title: String, category: String, productCode: String, colorNote: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCode = productCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedColor = colorNote.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty, !trimmedCategory.isEmpty, !trimmedCode.isEmpty else {
            return
        }

        items.insert(
            WardrobeItem(
                title: trimmedTitle,
                category: trimmedCategory,
                productCode: trimmedCode,
                colorNote: trimmedColor.isEmpty ? "Unspecified" : trimmedColor
            ),
            at: 0
        )
    }
}
