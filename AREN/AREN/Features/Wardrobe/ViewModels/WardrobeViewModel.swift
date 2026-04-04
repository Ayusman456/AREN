import Combine
import Foundation

@MainActor
final class WardrobeViewModel: ObservableObject {
    @Published var items: [WardrobeItem] = [
        WardrobeItem(
            title: "Zara Shirt Blue",
            category: "Tops",
            productCode: "AREN-SH-001",
            colorNote: "More colours",
            imageAssetName: "Outfit/shirt_blue",
            priceText: "₹ 2,550.00",
            colourSwatchHex: "#A8B7BB"
        ),
        WardrobeItem(
            title: "White Oxford",
            category: "Tops",
            productCode: "AREN-SH-002",
            colorNote: "White",
            imageAssetName: "Outfit/shirt_white",
            priceText: "₹ 2,350.00",
            colourSwatchHex: "#F7F7F5"
        ),
        WardrobeItem(
            title: "Dark Trouser",
            category: "Bottoms",
            productCode: "AREN-TR-009",
            colorNote: "More colours",
            imageAssetName: "Outfit/trousers_dark",
            priceText: "₹ 3,150.00",
            colourSwatchHex: "#5B6471"
        ),
        WardrobeItem(
            title: "Linen Trouser",
            category: "Bottoms",
            productCode: "AREN-TR-010",
            colorNote: "Sand",
            imageAssetName: "Outfit/trousers_linen",
            priceText: "₹ 2,850.00",
            colourSwatchHex: "#C9C1B2"
        ),
        WardrobeItem(
            title: "Derby",
            category: "Shoes",
            productCode: "AREN-SH-022",
            colorNote: "Black",
            imageAssetName: "Outfit/shoes_derby",
            priceText: "₹ 4,450.00",
            colourSwatchHex: "#2B2B2B"
        ),
        WardrobeItem(
            title: "Loafer",
            category: "Shoes",
            productCode: "AREN-SH-023",
            colorNote: "More colours",
            imageAssetName: "Outfit/shoes_loafer",
            priceText: "₹ 4,250.00",
            colourSwatchHex: "#6A5343"
        ),
    ]

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
