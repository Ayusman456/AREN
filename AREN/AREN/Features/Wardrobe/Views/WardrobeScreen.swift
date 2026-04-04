import SwiftUI

struct WardrobeScreen: View {
    let onBackTap: () -> Void
    let onFiltersTap: () -> Void
    let onSearchTap: () -> Void
    @StateObject private var viewModel = WardrobeViewModel()
    @State private var isPresentingAddItem = false
    @State private var selectedCategory = "All"

    private let columns = [
        GridItem(.fixed(171), spacing: 20),
        GridItem(.fixed(171), spacing: 20),
    ]

    init(
        onBackTap: @escaping () -> Void = {},
        onFiltersTap: @escaping () -> Void = {},
        onSearchTap: @escaping () -> Void = {}
    ) {
        self.onBackTap = onBackTap
        self.onFiltersTap = onFiltersTap
        self.onSearchTap = onSearchTap
    }

    var body: some View {
        VStack(spacing: 0) {
            WardrobeTopNavView(
                showsBackButton: false,
                onBackTap: onBackTap,
                onFiltersTap: onFiltersTap,
                onSearchTap: onSearchTap,
                onAddTap: { isPresentingAddItem = true }
            )

            WardrobeCategoryFilterStripView(
                selectedCategory: selectedCategory
            ) { category in
                selectedCategory = category
            }

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 32) {    //vertical gap between product-card rows
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
                .padding(.top, 0)
                .padding(.bottom, 0)
            }
        }
        .background(ArenColor.Surface.primary)
        .sheet(isPresented: $isPresentingAddItem) {
            AddItemView { title, category, productCode, colorNote in
                viewModel.addItem(title: title, category: category, productCode: productCode, colorNote: colorNote)
            }
        }
    }

    private var filteredItems: [WardrobeItem] {
        guard selectedCategory.caseInsensitiveCompare("all") != .orderedSame else {
            return viewModel.items
        }

        return viewModel.items.filter { item in
            item.category.caseInsensitiveCompare(selectedCategory) == .orderedSame
        }
    }
}

#Preview {
    WardrobeScreen()
}
