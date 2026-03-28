import SwiftUI

struct EventsScreen: View {
    @StateObject private var viewModel = EventsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.events.isEmpty {
                    ContentUnavailableView(
                        "No Events Yet",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Calendar sync is stubbed with demo data until EventKit is wired into permissions.")
                    )
                } else {
                    List(viewModel.events) { event in
                        VStack(alignment: .leading, spacing: ArenSpacing.xs) {
                            Text(event.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(ArenColor.Text.primary)

                            Text(event.timeLabel)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(ArenColor.Text.secondary)

                            if let location = event.location {
                                Text(location)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(ArenColor.Text.tertiary)
                            }
                        }
                        .padding(.vertical, ArenSpacing.xs)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Events")
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}

#Preview {
    EventsScreen()
}
