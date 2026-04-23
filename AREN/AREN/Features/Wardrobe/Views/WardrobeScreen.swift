import SwiftUI
import Kingfisher

struct WardrobeScreen: View {

    let onFiltersTap: () -> Void
    let onSearchTap: () -> Void
    let onAddTap: () -> Void

    @ObservedObject var viewModel: WardrobeViewModel
    @State private var selectedCategory = "All"

    // MARK: - Scroll State
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var isScrolling: Bool = false
    @State private var scrollDirection: ScrollDirection = .none
    @State private var navState: NavState = .solid

    // MARK: - Nav State Machine
    private enum ScrollDirection {
        case up, down, none
    }

    private enum NavState {
        case solid          // At top — all 3 bars fully solid
        case transparent    // Scrolling down — background 0, buttons visible
        case scrollingUp    // Scrolling up OR idle mid-page — all 3 bars at 0.85
    }

    // ✅ FIX 3 — Single shared opacity value used by ALL 3 bars
    private var sharedBackgroundOpacity: Double {
        switch navState {
        case .solid:        return 1.0
        case .transparent:  return 0.0
        case .scrollingUp:  return 0.95
        }
    }

    // ✅ FIX 2 — Secondary controls use same opacity, never independently hidden
    private var secondaryControlsOpacity: Double {
        switch navState {
        case .solid:        return 1.0
        case .transparent:  return 0.0
        case .scrollingUp:  return 0.95
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    private enum Layout {
        static let topSpacerHeight: CGFloat = 140
        static let bottomSpacerHeight: CGFloat = 100
        static let atTopThreshold: CGFloat = 4
    }

    var body: some View {
        ZStack(alignment: .top) {

            // MARK: - Scroll Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: Layout.topSpacerHeight)

                    if viewModel.activeTab == .items {
                        itemsGrid
                    } else {
                        outfitsGrid
                    }

                    Color.clear.frame(height: Layout.bottomSpacerHeight)
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y
            } action: { _, newOffset in
                // Direction detection with 2pt deadzone
                if newOffset > lastScrollOffset + 2 {
                    scrollDirection = .down
                } else if newOffset < lastScrollOffset - 2 {
                    scrollDirection = .up
                }
                lastScrollOffset = newOffset
                scrollOffset = newOffset

                // ✅ At top — snap everything to solid immediately
                if newOffset <= Layout.atTopThreshold {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        navState = .solid
                    }
                    return
                }

                // Mid-page direction-based state
                if isScrolling {
                    switch scrollDirection {
                    case .down:
                        withAnimation(.easeInOut(duration: 0.2)) {
                            navState = .transparent
                        }
                    case .up:
                        // ✅ FIX 2 — All 3 bars come back instantly at 0.85 on scroll up
                        withAnimation(.easeInOut(duration: 0.15)) {
                            navState = .scrollingUp
                        }
                    case .none:
                        break
                    }
                }
            }
            .onScrollPhaseChange { _, phase in
                switch phase {
                case .tracking, .interacting, .decelerating, .animating:
                    isScrolling = true

                case .idle:
                    isScrolling = false
                    // ✅ FIX 2 — On idle mid-page, stay at scrollingUp (0.85), never hide
                    if scrollOffset > Layout.atTopThreshold {
                        if navState != .solid {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                navState = .scrollingUp
                            }
                        }
                    }

                default:
                    break
                }
            }

            // MARK: - Floating Controls
            VStack(spacing: 0) {

                // ✅ FIX 1 — No .opacity modifier here. Buttons always visible.
                // ✅ FIX 3 — backgroundOpacity drives nav background, not a Bool
                WardrobeTopNavView(
                    mode: .filtersSearchAdd,
                    showsBackButton: false,
                    backgroundOpacity: sharedBackgroundOpacity,
                    onFiltersTap: onFiltersTap,
                    onSearchTap: onSearchTap,
                    onAddTap: onAddTap
                )

                // ✅ FIX 2 + FIX 3 — Same opacity as top nav, never independently hidden
                WardrobeTabToggleView(
                    selectedTab: $viewModel.activeTab,
                    itemCount: viewModel.filteredItems.count,
                    outfitCount: viewModel.filteredOutfits.count
                )
                .opacity(secondaryControlsOpacity)
                .animation(.easeInOut(duration: 0.2), value: secondaryControlsOpacity)

                // ✅ FIX 2 + FIX 3 — Same opacity as top nav, never independently hidden
                WardrobeCategoryFilterStripView(
                    selectedCategory: selectedCategory,
                    tab: viewModel.activeTab
                ) { category in
                    selectedCategory = category
                }
                .opacity(secondaryControlsOpacity)
                .animation(.easeInOut(duration: 0.2), value: secondaryControlsOpacity)
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
