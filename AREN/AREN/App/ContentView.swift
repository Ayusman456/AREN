import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()
    @State private var selectedTab: AppTab = .home
    @State private var presentedAuthContext: AuthContext?

    var body: some View {
        Group {
            if authService.isLaunching {
                SplashView()
            } else {
                TabView(selection: $selectedTab) {
                    HomeScreen { context in
                        presentedAuthContext = context
                    }
                    .tabItem {
                        Label("Home", systemImage: "sparkles")
                    }
                    .tag(AppTab.home)

                    WardrobeScreen()
                        .tabItem {
                            Label("Wardrobe", systemImage: "square.grid.2x2")
                        }
                        .tag(AppTab.wardrobe)

                    EventsScreen()
                        .tabItem {
                            Label("Events", systemImage: "calendar")
                        }
                        .tag(AppTab.events)

                    ProfileScreen(
                        sessionTitle: authService.sessionTitle,
                        sessionMessage: authService.sessionMessage
                    ) { context in
                        presentedAuthContext = context
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(AppTab.profile)
                }
                .tint(ArenColor.Fill.primary)
            }
        }
        .background(ArenColor.Surface.primary)
        .sheet(item: $presentedAuthContext) { context in
            AuthSheetView(context: context)
                .presentationDetents([.height(360)])
                .presentationDragIndicator(.visible)
        }
        .task {
            await authService.prepareSessionIfNeeded()
        }
    }
}

private enum AppTab {
    case home
    case wardrobe
    case events
    case profile
}

#Preview {
    ContentView()
}
