import SwiftUI

struct HomeView: View {
    @State private var activeTab: HomeTabBarItem = .home

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ScheduleRowView(
                    state: .withDate,
                    dateText: "SAT 21",
                    titleText: "CLIENT LUNCH",
                    timeText: "1:00 PM"
                )
                .frame(width: 402)

                OutfitCardEditorialStackView()
                    .padding(.top, 0)
                    .padding(.bottom, 8)

                DemoBannerCTAView(onTap: {})
            }
            .padding(.top, 0)

            Spacer(minLength: 0)

            HomeTabBarView(activeItem: activeTab) { selected in
                activeTab = selected
            }
        }
        .background(ArenColor.Surface.primary.ignoresSafeArea())
    }
}

#Preview {
    HomeView()
}
