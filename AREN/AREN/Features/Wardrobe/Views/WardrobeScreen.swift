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
        case .transparent:  return 0.0  // never fully 0 — safe area stays in sync visually
        case .scrollingUp:  return 0.95
        }
    }

    // ✅ FIX 2 — Secondary controls use same opacity, never independently hidden
    private var secondaryControlsOpacity: Double {
        switch navState {
        case .solid:        return 1.0
        case .transparent:  return 0.0  // never fully 0 — safe area stays in sync visually
        case .scrollingUp:  return 0.95
        }
    }

    private enum Layout {
        static let itemsTopSpacerHeight: CGFloat = 152
        static let bottomSpacerHeight: CGFloat = 100
        static let atTopThreshold: CGFloat = 4
        static let gridHorizontalInset: CGFloat = 20
        static let itemsColumnSpacing: CGFloat = 20
        static let itemsRowSpacing: CGFloat = 32
        static let itemCardWidth: CGFloat = 171
        static let outfitsColumnSpacing: CGFloat = 20
        static let outfitsRowSpacing: CGFloat = 32
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {

                // MARK: - Scroll Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: Layout.itemsTopSpacerHeight)

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
                        if scrollOffset > Layout.atTopThreshold {
                            if navState != .solid {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    if !isScrolling {
                                        withAnimation(.easeInOut(duration: 0.6)) {
                                            navState = .scrollingUp
                                        }
                                    }
                                }
                            }
                        }

                    default:
                        break
                    }
                }

                topSafeAreaBackground(height: proxy.safeAreaInsets.top)

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
        }
        .background(ArenColor.Surface.primary.ignoresSafeArea())
        .onChange(of: viewModel.activeTab) {
            selectedCategory = "All"
        }
        .task {
            await viewModel.fetchItems()
            await viewModel.fetchOutfits()
        }
    }

    private func topSafeAreaBackground(height: CGFloat) -> some View {
        ArenColor.Surface.primary
            .opacity(sharedBackgroundOpacity)
            .frame(maxWidth: .infinity)
            .frame(height: height, alignment: .top)
            .ignoresSafeArea(edges: .top)
            .animation(.easeInOut(duration: 0.2), value: sharedBackgroundOpacity)
    }

    // MARK: - Grids

    private var itemsGrid: some View {
        LazyVGrid(columns: itemColumns, spacing: Layout.itemsRowSpacing) {
            ForEach(categoryFilteredItems) { item in
                WardrobeItemCell(item: item)
            }
        }
        .padding(.horizontal, Layout.gridHorizontalInset)
    }

    private var outfitsGrid: some View {
        LazyVGrid(columns: outfitColumns, spacing: Layout.outfitsRowSpacing) {
            ForEach(viewModel.filteredOutfits) { outfit in
                WardrobeOutfitCell(outfit: outfit, onTap: {})
            }
        }
        .padding(.horizontal, Layout.gridHorizontalInset)
    }

    private var itemColumns: [GridItem] {
        [
            GridItem(.fixed(Layout.itemCardWidth), spacing: Layout.itemsColumnSpacing),
            GridItem(.fixed(Layout.itemCardWidth), spacing: 0),
        ]
    }

    private var outfitColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: Layout.outfitsColumnSpacing),
            GridItem(.flexible(), spacing: 0),
        ]
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
