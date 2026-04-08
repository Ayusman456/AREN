import SwiftUI

struct HomeView: View {
    @State private var isOutfitSaved = false

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
                    .overlay(alignment: .topTrailing) {
                        // Keep the save affordance as an overlay so it doesn't affect the
                        // underlying card layout or the home screen spacing.
                        BookmarkSaveButtonView(isSaved: isOutfitSaved) {
                            isOutfitSaved.toggle()
                        }
                        // Match the Figma save placement: visually attached to the outfit
                        // card, but still treated as a parent-owned action in HomeView.
                        .padding(.top, 16)
                        .padding(.trailing, 20)
                    }

            }
            .padding(.top, 0)

            Spacer(minLength: 0)
        }
        .background(ArenColor.Surface.primary)
    }
}

#Preview {
    HomeView()
}
