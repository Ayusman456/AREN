import SwiftUI

struct NavigationContainer: View {
    @EnvironmentObject var router: AppRouter
    let activeTab: HomeTabBarItem
    @Binding var showAddItemSource: Bool
    @ObservedObject var wardrobeViewModel: WardrobeViewModel

    private var authSheetBinding: Binding<AppSheet?> {
        Binding(
            get: {
                guard case .authSheet = router.activeSheet else { return nil }
                return router.activeSheet
            },
            set: { newValue in
                router.activeSheet = newValue
            }
        )
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            rootView(for: activeTab)
                .navigationBarHidden(true)
                .toolbarBackground(.hidden, for: .navigationBar)
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .wardrobeSearch:
                        WardrobeSearchScreen(onCancelTap: { router.pop() })
                            .navigationBarHidden(true)
                            .toolbarBackground(.hidden, for: .navigationBar)
                    case .addItem:
                        EmptyView()
                    }
                }
        }
        .sheet(item: authSheetBinding) { sheet in
            switch sheet {
            case .addItemSource, .addItemCategory:
                EmptyView()
            case .authSheet(let context):
                AuthSheetView(context: context)
            case .wardrobeFilters, .dayDetail:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func rootView(for tab: HomeTabBarItem) -> some View {
        switch tab {
        case .home:
            HomeView()
                .environmentObject(router)
        case .wardrobe:
            WardrobeScreen(
                viewModel: wardrobeViewModel,
                onFiltersTap: { router.present(sheet: .wardrobeFilters) },
                onSearchTap: { router.navigate(to: .wardrobeSearch) },
                onAddTap: { showAddItemSource = true }
            )
        case .events:
            PlaceholderSectionView(title: "Events")
        case .profile:
            PlaceholderSectionView(title: "Profile")
        }
    }
}
