import Combine
import Foundation

@MainActor
final class WardrobeViewModel: ObservableObject {
    @Published var items: [WardrobeItem] = [
        WardrobeItem(title: "White Oxford", category: "Shirts", productCode: "AREN-SH-001", colorNote: "White"),
        WardrobeItem(title: "Dark Trouser", category: "Trousers", productCode: "AREN-TR-009", colorNote: "Charcoal"),
        WardrobeItem(title: "Derby", category: "Shoes", productCode: "AREN-SH-022", colorNote: "Black"),
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
