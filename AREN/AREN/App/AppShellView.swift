import SwiftUI

struct AppShellView: View {
    @State private var currentScreen: AppScreen = .home
    @State private var isPresentingWardrobeFilters = false
    @State private var wardrobeSelectedFilterValues: [String: String] = [
        "01-sort by": "Recently added",
        "02-status": "All",
        "03-occasion": "All",
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                screenContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                if currentScreen.showsTabBar {
                    HomeTabBarView(activeItem: currentScreen.tabBarItem ?? .home) { item in
                        selectTab(item)
                    }
                }
            }
            .background(ArenColor.Surface.primary.ignoresSafeArea())

            if isPresentingWardrobeFilters {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        isPresentingWardrobeFilters = false
                    }

                // The filter modal belongs to the app shell so it can rise from the
                // true bottom edge of the device and overlay the tab bar, matching
                // the Zara-style behavior more closely than a screen-local sheet.
                WardrobeFilterPanelView(
                    selectedValues: wardrobeSelectedFilterValues,
                    onSelectOption: { sectionID, option in
                        wardrobeSelectedFilterValues[sectionID] = option
                    },
                    onViewResults: {
                        isPresentingWardrobeFilters = false
                    }
                )
                .frame(maxWidth: .infinity)
                .background(ArenColor.Surface.primary)
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.easeOut(duration: 0.2), value: isPresentingWardrobeFilters)
        // LayoutGridOverlayView()
    }

    @ViewBuilder
    private var screenContent: some View {
        if currentScreen == .home {
            HomeView()
        } else if currentScreen == .wardrobe {
            WardrobeScreen(onBackTap: {
                currentScreen = .home
            }, onFiltersTap: {
                isPresentingWardrobeFilters = true
            }, onSearchTap: {
                currentScreen = .wardrobeSearch
            })
        } else if currentScreen == .wardrobeSearch {
            WardrobeSearchScreen(onCancelTap: {
                currentScreen = .wardrobe
            })
        } else if currentScreen == .events {
            PlaceholderSectionView(title: "Events")
        } else if currentScreen == .profile {
            PlaceholderSectionView(title: "Profile")
        }
    }

    private func selectTab(_ item: HomeTabBarItem) {
        currentScreen = AppScreen(tabBarItem: item)
    }
}

private enum AppScreen: Hashable {
    case home
    case wardrobe
    case wardrobeSearch
    case events
    case profile

    // The shell owns tab-bar visibility so future full-screen routes can opt
    // out here without each child screen managing global navigation chrome.
    var showsTabBar: Bool {
        switch self {
        case .home, .wardrobe, .events, .profile:
            return true
        case .wardrobeSearch:
            return false
        }
    }

    var tabBarItem: HomeTabBarItem? {
        switch self {
        case .home:
            return .home
        case .wardrobe:
            return .wardrobe
        case .wardrobeSearch:
            return nil
        case .events:
            return .events
        case .profile:
            return .profile
        }
    }

    init(tabBarItem: HomeTabBarItem) {
        switch tabBarItem {
        case .home:
            self = .home
        case .wardrobe:
            self = .wardrobe
        case .events:
            self = .events
        case .profile:
            self = .profile
        }
    }
}

private struct PlaceholderSectionView: View {
    let title: String

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            Text(title)
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(ArenColor.Text.primary)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ArenColor.Surface.primary)
    }
}

#Preview {
    AppShellView()
}
