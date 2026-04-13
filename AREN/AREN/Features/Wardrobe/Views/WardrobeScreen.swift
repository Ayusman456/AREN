import SwiftUI
import Kingfisher

struct WardrobeScreen: View {
    let onFiltersTap: () -> Void
    let onSearchTap: () -> Void
    let onAddTap: () -> Void

    @StateObject private var viewModel = WardrobeViewModel()
    @State private var selectedCategory = "All"
    @State private var selectedTab: WardrobeTab = .items

    private let columns = [
        GridItem(.fixed(171), spacing: 20),
        GridItem(.fixed(171), spacing: 20)
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
                outfitCount: viewModel.outfits.count
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
        .task {
            await viewModel.fetchItems()
        }
    }

    // MARK: - Items Grid

    private var itemsGrid: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 32) {
            ForEach(filteredItems) { item in
                WardrobeItemCell(item: item)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Outfits Grid

    private var outfitsGrid: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 32) {
            ForEach(viewModel.outfits) { outfit in
                // wire WardrobeOutfitCell here once model is updated
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Filtered Items

    private var filteredItems: [WardrobeItem] {
        guard selectedCategory.caseInsensitiveCompare("all") != .orderedSame else {
            return viewModel.items
        }
        return viewModel.items.filter {
            ($0.category ?? "").caseInsensitiveCompare(selectedCategory) == .orderedSame
        }
    }
}

#Preview {
    WardrobeScreen()
}
