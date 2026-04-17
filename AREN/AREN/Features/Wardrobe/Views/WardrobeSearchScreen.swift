import SwiftUI

struct WardrobeSearchScreen: View {
    let onCancelTap: () -> Void
    let onItemTap: (WardrobeItem) -> Void
    @ObservedObject var wardrobeViewModel: WardrobeViewModel
    @State private var query = ""
    @FocusState private var isSearchFieldFocused: Bool

    init(
        onCancelTap: @escaping () -> Void = {},
        onItemTap: @escaping (WardrobeItem) -> Void = { _ in },
        wardrobeViewModel: WardrobeViewModel
    ) {
        self.onCancelTap = onCancelTap
        self.onItemTap = onItemTap
        self.wardrobeViewModel = wardrobeViewModel
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
            await wardrobeViewModel.fetchItems()
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
        Array(wardrobeViewModel.items.prefix(4))
    }

    private var filteredItems: [WardrobeItem] {
        guard !trimmedQuery.isEmpty else { return wardrobeViewModel.items }
        let normalizedQuery = trimmedQuery.uppercased()
        return wardrobeViewModel.items.filter { item in
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
    WardrobeSearchScreen(
        wardrobeViewModel: WardrobeViewModel()
    )
}
