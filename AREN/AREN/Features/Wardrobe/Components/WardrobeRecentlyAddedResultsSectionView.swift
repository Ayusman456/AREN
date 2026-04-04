import SwiftUI
import UIKit

struct WardrobeRecentlyAddedResultsSectionView: View {
    struct ResultItem: Identifiable, Hashable {
        let id: UUID
        let imageAssetName: String
        let titleText: String
    }

    let items: [ResultItem]
    let showsSectionTitle: Bool
    let sectionTitle: String
    let onAddTap: (ResultItem) -> Void
    let onItemTap: (ResultItem) -> Void

    init(
        showsSectionTitle: Bool = false,
        sectionTitle: String = "YOUR ITEMS",
        items: [ResultItem] = Self.previewItems,
        onAddTap: @escaping (ResultItem) -> Void = { _ in },
        onItemTap: @escaping (ResultItem) -> Void = { _ in }
    ) {
        self.showsSectionTitle = showsSectionTitle
        self.sectionTitle = sectionTitle
        self.items = items
        self.onAddTap = onAddTap
        self.onItemTap = onItemTap
    }

    private let columns = [
        GridItem(.fixed(171), spacing: 20),
        GridItem(.fixed(171), spacing: 20),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: showsSectionTitle ? 24 : 0) {
            if showsSectionTitle {
                Text(sectionTitle.uppercased())
                    .font(Self.sectionHeaderFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .frame(maxWidth: .infinity, minHeight: 16, alignment: .leading)
            }

            LazyVGrid(columns: columns, alignment: .leading, spacing: 32) {
                ForEach(items) { item in
                    WardrobeSearchResultCardView(
                        imageAssetName: item.imageAssetName,
                        titleText: item.titleText,
                        onAddTap: { onAddTap(item) },
                        onTap: { onItemTap(item) }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(width: 402, alignment: .top)
        .background(ArenColor.Surface.primary)
    }

    private static let previewItems: [ResultItem] = [
        ResultItem(
            id: UUID(),
            imageAssetName: "Outfit/trousers_linen",
            titleText: "Slim fit cropped jeans"
        ),
        ResultItem(
            id: UUID(),
            imageAssetName: "Outfit/trousers_dark",
            titleText: "Slim fit jeans"
        ),
        ResultItem(
            id: UUID(),
            imageAssetName: "Outfit/trousers_chino",
            titleText: "Regular fit jeans"
        ),
    ]

    private static var sectionHeaderFont: Font {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular",
        ]

        for name in candidates where UIFont(name: name, size: 12) != nil {
            return .custom(name, size: 12)
        }

        return .system(size: 12, weight: .light)
    }
}

#Preview {
    WardrobeRecentlyAddedResultsSectionView()
        .background(Color.white)
}
