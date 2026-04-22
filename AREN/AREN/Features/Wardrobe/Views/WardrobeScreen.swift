import SwiftUI
import Kingfisher

struct WardrobeScreen: View {

    let onFiltersTap: () -> Void
    let onSearchTap: () -> Void
    let onAddTap: () -> Void

    @ObservedObject var viewModel: WardrobeViewModel
    @State private var selectedCategory = "All"

    // MARK: - Scroll State
    // ✅ FIX 1 — Removed unused scrollOffset state
    @State private var isScrolling: Bool = false
    @State private var showControls: Bool = true

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack(alignment: .top) {

            // MARK: - Scroll Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {

                    // Top spacing for overlay
                    Color.clear.frame(height: 140)

                    if viewModel.activeTab == .items {
                        itemsGrid
                    } else {
                        outfitsGrid
                    }

                    Color.clear.frame(height: 100)
                }
            }
            // ✅ FIX 1 — onScrollGeometryChange removed entirely (scrollOffset was unused)
            .onScrollPhaseChange { _, phase in
                // ✅ FIX 2 — Handle decelerating + animating phases
                switch phase {
                case .tracking, .interacting, .decelerating, .animating:
                    isScrolling = true
                    hideControls()

                case .idle:
                    isScrolling = false
                    showControlsWithDelay()

                default:
                    break
                }
            }

            // MARK: - Floating Controls
            VStack(spacing: 0) {

                // Top Nav
                WardrobeTopNavView(
                    mode: .filtersSearchAdd,
                    showsBackButton: false,
                    isTransparent: !showControls,
                    onFiltersTap: onFiltersTap,
                    onSearchTap: onSearchTap,
                    onAddTap: onAddTap
                )

                // Tabs
                // ✅ FIX 4 — Reduced offset from -20 to -8 to prevent clipping under nav
                WardrobeTabToggleView(
                    selectedTab: $viewModel.activeTab,
                    itemCount: viewModel.filteredItems.count,
                    outfitCount: viewModel.filteredOutfits.count
                )
                .opacity(showControls ? 1 : 0)
                .offset(y: showControls ? 0 : -8)
                .animation(.easeInOut(duration: 0.2), value: showControls)

                // Category Strip
                // ✅ FIX 4 — Reduced offset from -20 to -8 to prevent clipping under nav
                WardrobeCategoryFilterStripView(
                    selectedCategory: selectedCategory,
                    tab: viewModel.activeTab
                ) { category in
                    selectedCategory = category
                }
                .opacity(showControls ? 1 : 0)
                .offset(y: showControls ? 0 : -8)
                .animation(.easeInOut(duration: 0.2), value: showControls)
            }
        }
        .background(ArenColor.Surface.primary)
        .onChange(of: viewModel.activeTab) {
            selectedCategory = "All"
        }
        .task {
            await viewModel.fetchItems()
            await viewModel.fetchOutfits()
        }
    }

    // MARK: - Animations

    private func hideControls() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showControls = false
        }
    }

    // ✅ FIX 3 — Delay reduced from 0.7s to 0.15s for snappy restore on scroll up
    private func showControlsWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if !isScrolling {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showControls = true
                }
            }
        }
    }

    // MARK: - Grids

    private var itemsGrid: some View {
        LazyVGrid(columns: columns, spacing: 32) {
            ForEach(categoryFilteredItems) { item in
                WardrobeItemCell(item: item)
            }
        }
        .padding(.horizontal, 20)
    }

    private var outfitsGrid: some View {
        LazyVGrid(columns: columns, spacing: 32) {
            ForEach(viewModel.filteredOutfits) { outfit in
                WardrobeOutfitCell(outfit: outfit, onTap: {})
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Filtering

    private var categoryFilteredItems: [WardrobeItem] {
        guard selectedCategory.caseInsensitiveCompare("all") != .orderedSame else {
            return viewModel.filteredItems
        }
        return viewModel.filteredItems.filter {
            ($0.category ?? "").caseInsensitiveCompare(selectedCategory) == .orderedSame
        }
    }
}
