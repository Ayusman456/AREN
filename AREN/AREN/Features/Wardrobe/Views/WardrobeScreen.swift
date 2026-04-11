import SwiftUI

struct WardrobeScreen: View {
    let onFiltersTap: () -> Void
    let onSearchTap: () -> Void
    let onAddTap: () -> Void

    @StateObject private var viewModel = WardrobeViewModel()
    @State private var isPresentingAddItem = false
    @State private var selectedCategory = "All"
    @State private var selectedTab: WardrobeTab = .items

    // MARK: - Grid Columns

    private let itemColumns = [
        GridItem(.fixed(171), spacing: 20),
        GridItem(.fixed(171), spacing: 20),
    ]

    private let outfitColumns = [
        GridItem(.fixed(171), spacing: 20),
        GridItem(.fixed(171), spacing: 20),
    ]

    init(
        onFiltersTap: @escaping () -> Void = {},
        onSearchTap: @escaping () -> Void = {},
        onAddTap: @escaping () -> Void = {}
    ) {
        self.onFiltersTap = onFiltersTap
        self.onSearchTap = onSearchTap
        self.onAddTap = onAddTap
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            WardrobeTopNavView(
                mode: .filtersSearchAdd,
                showsBackButton: false,
                onFiltersTap: onFiltersTap,
                onSearchTap: onSearchTap,
                onAddTap: onAddTap
            )

            WardrobeTabToggleView(
                selectedTab: $selectedTab,
                itemCount: viewModel.items.count,
                outfitCount: placeholderOutfits.count
            )
            .onChange(of: selectedTab) {
                selectedCategory = "All"
            }

            WardrobeCategoryFilterStripView(
                selectedCategory: selectedCategory,
                tab: selectedTab
            ) { category in
                selectedCategory = category
            }

            ScrollView(.vertical, showsIndicators: false) {
                if selectedTab == .items {
                    itemsGrid
                } else {
                    outfitsGrid
                }
            }
        }
        .background(ArenColor.Surface.primary)
        .sheet(isPresented: $isPresentingAddItem) {
            AddItemView { title, category, productCode, colorNote in
                viewModel.addItem(title: title, category: category, productCode: productCode, colorNote: colorNote)
            }
        }
    }

    // MARK: - Items Grid (original layout restored)

    private var itemsGrid: some View {
        LazyVGrid(columns: itemColumns, alignment: .leading, spacing: 32) {
            ForEach(filteredItems) { item in
                WardrobeProductCardView(
                    imageAssetName: item.imageAssetName,
                    titleText: item.title,
                    priceText: nil,
                    coloursText: nil,
                    colourSwatchHex: item.colourSwatchHex,
                    showsAddButton: item.showsAddButton,
                    onAddTap: { isPresentingAddItem = true }
                )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Outfits Grid (placeholder using existing card)

    private var outfitsGrid: some View {
        LazyVGrid(columns: outfitColumns, alignment: .leading, spacing: 32) {
            ForEach(placeholderOutfits.indices, id: \.self) { index in
                let outfit = placeholderOutfits[index]
                WardrobeProductCardView(
                    imageAssetName: outfit.imageAssetName,
                    titleText: outfit.title,
                    priceText: nil,
                    coloursText: nil,
                    colourSwatchHex: nil,
                    showsAddButton: false,
                    onAddTap: nil
                )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Placeholder Outfit Data

    private var placeholderOutfits: [(title: String, subtitle: String, imageAssetName: String)] {
        [
            (title: "WORK", subtitle: "3 PIECES", imageAssetName: "tops_002"),
            (title: "WORK", subtitle: "4 PIECES", imageAssetName: "tops_001"),
            (title: "CASUAL", subtitle: "3 PIECES", imageAssetName: "tops_001"),
            (title: "CASUAL", subtitle: "4 PIECES", imageAssetName: "tops_002"),
            (title: "DATE", subtitle: "3 PIECES", imageAssetName: "tops_001"),
            (title: "WORK", subtitle: "2 PIECES", imageAssetName: "tops_002"),
            (title: "EVENTS", subtitle: "4 PIECES", imageAssetName: "tops_001"),
            (title: "CASUAL", subtitle: "3 PIECES", imageAssetName: "tops_002"),
        ]
    }

    // MARK: - Filtered Items

    private var filteredItems: [WardrobeItem] {
        guard selectedCategory.caseInsensitiveCompare("all") != .orderedSame else {
            return viewModel.items
        }
        return viewModel.items.filter {
            $0.category.caseInsensitiveCompare(selectedCategory) == .orderedSame
        }
    }
}

#Preview {
    WardrobeScreen()
}
