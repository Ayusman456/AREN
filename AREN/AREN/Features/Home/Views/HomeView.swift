import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter

    // MARK: - State

    @State private var isOutfitSaved = false

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

            OutfitCardEditorialStackView()
                .padding(.bottom, 8)
                .overlay(alignment: .topTrailing) {
                    BookmarkSaveButtonView(isSaved: isOutfitSaved) {
                        isOutfitSaved.toggle()
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 20)
                }

            Spacer(minLength: 0)
        }
        .background(ArenColor.Surface.primary)
    }
}

#Preview {
    HomeView()
}
