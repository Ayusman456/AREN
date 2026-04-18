import SwiftUI
import Kingfisher

struct WardrobeScreen: View {
    #if DEBUG
    private let showDebugBorders = false
    #else
    private let showDebugBorders = false
    #endif

    let onFiltersTap: () -> Void
    let onSearchTap: () -> Void
    let onAddTap: () -> Void

    @ObservedObject var viewModel: WardrobeViewModel
    @State private var selectedCategory = "All"
    @State private var selectedTab: WardrobeTab = .items

    private let columns = [
        GridItem(.fixed(171), spacing: 20),
        GridItem(.fixed(171), spacing: 20)
    ]

    init(
        viewModel: WardrobeViewModel,
        onFiltersTap: @escaping () -> Void = {},
        onSearchTap: @escaping () -> Void = {},
        onAddTap: @escaping () -> Void = {}
    ) {
        self.viewModel = viewModel
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
            .debugBorder(if: showDebugBorders, color: .orange)

            WardrobeTabToggleView(
                selectedTab: $selectedTab,
                itemCount: viewModel.items.count,
                outfitCount: viewModel.outfits.count
            )
            .onChange(of: selectedTab) {
                selectedCategory = "All"
            }
            .debugBorder(if: showDebugBorders, color: .blue)

            WardrobeCategoryFilterStripView(
                selectedCategory: selectedCategory,
                tab: selectedTab
            ) { category in
                selectedCategory = category
            }
            .debugBorder(if: showDebugBorders, color: .green)

            ScrollView(.vertical, showsIndicators: false) {
                if selectedTab == .items {
                    itemsGrid
                } else {
                    outfitsGrid
                }
            }
            .debugBorder(if: showDebugBorders, color: .purple)
        }
        .background(ArenColor.Surface.primary)
        .task {
            await viewModel.fetchItems()
        }
        .debugBorder(if: showDebugBorders, color: .red)
    }

    // MARK: - Items Grid

    private var itemsGrid: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 32) {
            ForEach(filteredItems) { item in
                WardrobeItemCell(item: item)
                    .debugBorder(if: showDebugBorders, color: .pink)
            }
        }
        .padding(.horizontal, 20)
        .debugBorder(if: showDebugBorders, color: .cyan)
    }

    // MARK: - Outfits Grid

    private var outfitsGrid: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 32) {
            ForEach(viewModel.outfits) { outfit in
                Group {
                    // wire WardrobeOutfitCell here once model is updated
                }
            }
        }
        .padding(.horizontal, 20)
        .debugBorder(if: showDebugBorders, color: .mint)
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
    WardrobeScreen(viewModel: WardrobeViewModel())
}
