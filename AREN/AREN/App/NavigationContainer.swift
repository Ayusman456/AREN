import SwiftUI

struct NavigationContainer: View {
    @EnvironmentObject var router: AppRouter
    let activeTab: HomeTabBarItem
    @Binding var showAddItemSource: Bool
    @ObservedObject var homeViewModel: HomeViewModel
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

    private var filtersSheetBinding: Binding<AppSheet?> {
        Binding(
            get: {
                guard case .wardrobeFilters = router.activeSheet else { return nil }
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
                        WardrobeSearchScreen(
                            onCancelTap: { router.pop() },
                            wardrobeViewModel: wardrobeViewModel
                        )
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
        .overlay {
         //   let _ = print("overlay check — activeSheet:", String(describing: router.activeSheet)) // Debugging print
            if case .wardrobeFilters = router.activeSheet {
                filterPanelOverlay
            }
        }
    }

    // MARK: - Filter Panel Overlay

    private var filterPanelOverlay: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture { router.activeSheet = nil }

            WardrobeFilterPanelView(
                sections: activeWardrobeTab == .items
                    ? WardrobeFilterPanelView.itemsSections
                    : WardrobeFilterPanelView.outfitsSections,
                selectedValues: activeWardrobeTab == .items
                    ? wardrobeViewModel.itemFilters
                    : wardrobeViewModel.outfitFilters,
                onSelectOption: { sectionId, option in
                  //  print("onSelectOption called:", sectionId, option) // Debugging print
                    if activeWardrobeTab == .items {
                        wardrobeViewModel.itemFilters[sectionId] = option
                    } else {
                        wardrobeViewModel.outfitFilters[sectionId] = option
                    }
                },
                onViewResults: { router.activeSheet = nil }
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Active Wardrobe Tab

    // Reads active tab from WardrobeScreen indirectly via ViewModel
    // Defaults to .items — filter panel shows itemsSections unless outfits tab is active
    private var activeWardrobeTab: WardrobeTab {
        wardrobeViewModel.activeTab
    }

    // MARK: - Root Views

    @ViewBuilder
    private func rootView(for tab: HomeTabBarItem) -> some View {
        switch tab {
        case .home:
            HomeView(homeViewModel: homeViewModel)
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
