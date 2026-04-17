import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject var homeViewModel: HomeViewModel

    // MARK: - Demo Data

    private let demoEvents: [DayDetailModalView.ScheduleEvent] = [
        .init(title: "Client Lunch",   timeText: "1:00 PM", occasion: "Business Casual"),
        .init(title: "Team Standup",   timeText: "3:00 PM", occasion: "Business"),
        .init(title: "Dinner with Sara", timeText: "7:30 PM", occasion: "Evening")
    ]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ScheduleRowView(
                state: .withDate,
                dateText: "SAT 21",
                titleText: "CLIENT LUNCH",
                timeText: "1:00 PM",
                overflowCount: 2,
                onOverflowTap: {
                    router.present(sheet: .dayDetail(date: .now, events: demoEvents))
                }
            )

            if homeViewModel.isLoading {
                loadingSkeleton
            } else {
                outfitCanvas
            }

            Spacer(minLength: 0)
        }
        .background(ArenColor.Surface.primary)
        .task {
            homeViewModel.loadOutfitIfNeeded()  // FIX 2: use guard, not force-reload
        }
    }

    // MARK: - Outfit Canvas

    private var outfitCanvas: some View {
        ZStack(alignment: .topTrailing) {
            OutfitCardEditorialStackView(
                tops:    homeViewModel.tops,
                bottoms: homeViewModel.bottoms,
                shoes:   homeViewModel.shoes,
                topIndex:    $homeViewModel.topIndex,
                bottomIndex: $homeViewModel.bottomIndex,
                shoesIndex:  $homeViewModel.shoesIndex,
                captionText: homeViewModel.displayCaption.isEmpty
                    ? "Your outfit for today"
                    : homeViewModel.displayCaption
            )

            // FIX 3: bind directly to VM — single source of truth
            BookmarkSaveButtonView(isSaved: homeViewModel.isOutfitSaved) {
                homeViewModel.isOutfitSaved.toggle()
            }
            .padding(.top, 16)
            .padding(.trailing, 20)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Loading Skeleton

    private var loadingSkeleton: some View {
        VStack(spacing: 8) {
            skeletonRow(height: OutfitLayout.topsHeight)
            skeletonRow(height: OutfitLayout.bottomsHeight)
            skeletonRow(height: OutfitLayout.shoesHeight)
        }
        .padding(.vertical, OutfitLayout.canvasVerticalPadding)
        .frame(maxWidth: .infinity)
    }

    private func skeletonRow(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(ArenColor.Surface.secondary)
            .frame(maxWidth: OutfitLayout.canvasWidth)
            .frame(height: height)
            .opacity(0.5)
            .shimmering()
    }
}

// MARK: - Shimmer Modifier

extension View {
    func shimmering() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear,                    location: phase - 0.3),
                        .init(color: Color.white.opacity(0.4),  location: phase),
                        .init(color: .clear,                    location: phase + 0.3)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .blendMode(.plusLighter)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1.3
                }
            }
    }
}

// MARK: - Preview

#Preview {
    HomeView(homeViewModel: HomeViewModel())
        .environmentObject(AppRouter())
}
