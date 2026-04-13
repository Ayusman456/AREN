import SwiftUI

struct WardrobeSearchScreen: View {
    let onCancelTap: () -> Void
    let onItemTap: (WardrobeItem) -> Void
    @StateObject private var viewModel = WardrobeViewModel()
    @State private var query = ""
    @FocusState private var isSearchFieldFocused: Bool

    init(
        onCancelTap: @escaping () -> Void = {},
        onItemTap: @escaping (WardrobeItem) -> Void = { _ in }
    ) {
        self.onCancelTap = onCancelTap
        self.onItemTap = onItemTap
    }

    var body: some View {
        VStack(spacing: 0) {
            WardrobeTopNavView(
                mode: .cancel,
                showsBackButton: false,
                onBackTap: onCancelTap
            )

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    WardrobeSearchPanelHeaderView(
                        recentHeaderText: sectionHeaderText,
                        query: $query,
                        isSearchFieldFocused: $isSearchFieldFocused
                    )

                    WardrobeRecentlyAddedResultsSectionView(
                        items: visibleItems.map(makeResultItem),
                        onItemTap: { result in
                            guard let selectedItem = visibleItems.first(where: { $0.id == result.id }) else {
                                return
                            }
                            onItemTap(selectedItem)
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ArenColor.Surface.primary)
        .task {
            await viewModel.fetchItems()
        }
    }

    // MARK: - Computed

    private var sectionHeaderText: String {
        trimmedQuery.isEmpty ? "RECENTLY ADDED" : "YOUR ITEMS"
    }

    private var visibleItems: [WardrobeItem] {
        trimmedQuery.isEmpty ? recentlyAddedItems : filteredItems
    }

    private var recentlyAddedItems: [WardrobeItem] {
        Array(viewModel.items.prefix(4))
    }

    private var filteredItems: [WardrobeItem] {
        guard !trimmedQuery.isEmpty else { return viewModel.items }
        let normalizedQuery = trimmedQuery.uppercased()
        return viewModel.items.filter { item in
            [item.name, item.category ?? ""]
                .map { $0.uppercased() }
                .contains { $0.contains(normalizedQuery) }
        }
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func makeResultItem(from item: WardrobeItem) -> WardrobeRecentlyAddedResultsSectionView.ResultItem {
        .init(id: item.id, imageAssetName: item.imageURL ?? "", titleText: item.name)
    }
}

#Preview {
    WardrobeSearchScreen()
}
