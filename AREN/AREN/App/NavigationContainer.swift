import SwiftUI

struct NavigationContainer: View {
    @EnvironmentObject var router: AppRouter
    let activeTab: HomeTabBarItem

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
        .sheet(item: $router.activeSheet) { sheet in
            switch sheet {
            case .wardrobeFilters:
                EmptyView()
            case .authSheet(let context):
                AuthSheetView(context: context)
            }
        }
    }

    @ViewBuilder
    private func rootView(for tab: HomeTabBarItem) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .wardrobe:
            WardrobeScreen(
                onFiltersTap: { router.present(sheet: .wardrobeFilters) },
                onSearchTap: { router.navigate(to: .wardrobeSearch) },
                onAddTap: {}
            )
        case .events:
            PlaceholderSectionView(title: "Events")
        case .profile:
            PlaceholderSectionView(title: "Profile")
        }
    }
}
