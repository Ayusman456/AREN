import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject var homeViewModel: HomeViewModel

    // MARK: - State

    @State private var isOutfitSaved = false
    @State private var currentOutfitIndex: Int = 0

    // MARK: - Demo Data
    // TODO: Replace with real data from view model

    private let demoEvents: [DayDetailModalView.ScheduleEvent] = [
        .init(title: "Client Lunch", timeText: "1:00 PM", occasion: "Business Casual"),
        .init(title: "Team Standup", timeText: "3:00 PM", occasion: "Business"),
        .init(title: "Dinner with Sara", timeText: "7:30 PM", occasion: "Evening"),
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
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TabView(selection: $currentOutfitIndex) {
                    ForEach(homeViewModel.outfits.indices, id: \.self) { index in
                        let outfit = homeViewModel.outfits[index]
                        OutfitCardEditorialStackView(
                            tops: OutfitCategory(items: outfit.top
                                .flatMap { URL(string: $0.imageURL ?? "") }
                                .map { [.remote($0)] } ?? [.asset("shirt_blue")]),
                            bottoms: OutfitCategory(items: outfit.bottom
                                .flatMap { URL(string: $0.imageURL ?? "") }
                                .map { [.remote($0)] } ?? [.asset("trousers_dark")]),
                            shoes: OutfitCategory(items: outfit.shoes
                                .flatMap { URL(string: $0.imageURL ?? "") }
                                .map { [.remote($0)] } ?? [.asset("shoes_loafer")])
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .padding(.bottom, 8)
                .overlay(alignment: .topTrailing) {
                    BookmarkSaveButtonView(isSaved: isOutfitSaved) {
                        isOutfitSaved.toggle()
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 20)
                }
            }
            Spacer(minLength: 0)
        }
        .background(ArenColor.Surface.primary)
        .task {
            await homeViewModel.fetchDailyOutfit()
        }
    }
}

#Preview {
    HomeView(homeViewModel: HomeViewModel())
}
