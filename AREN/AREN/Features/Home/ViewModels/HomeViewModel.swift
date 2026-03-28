import Combine
import Foundation
import SwiftUI

struct HomeOutfitCard: Identifiable, Hashable {
    let id = UUID()
    let assetName: String
    let title: String
    let note: String
}

struct SwipeRowState: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let items: [HomeOutfitCard]
    var activeIndex: Int = 0

    var activeItem: HomeOutfitCard {
        items[activeIndex]
    }
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var rows: [SwipeRowState] = HomeViewModel.defaultRows
    @Published private(set) var contextTitle = "Today"
    @Published private(set) var contextSubtitle = "Loading weather and calendar"
    @Published private(set) var reasoningLine = "Building your first ARĒN outfit."
    @Published private(set) var demoBannerText = "Demo wardrobe loaded with seed outfit pieces."
    @Published private(set) var wearHistoryCount = 0

    private let weatherService: WeatherService
    private let calendarService: CalendarService
    private var hasLoadedContext = false

    init() {
        self.weatherService = WeatherService()
        self.calendarService = CalendarService()
        refreshReasoning()
    }

    init(
        weatherService: WeatherService,
        calendarService: CalendarService
    ) {
        self.weatherService = weatherService
        self.calendarService = calendarService
        refreshReasoning()
    }

    func loadIfNeeded() async {
        guard !hasLoadedContext else { return }
        hasLoadedContext = true

        async let weather = weatherService.fetchTodaySnapshot()
        async let events = calendarService.fetchUpcomingEvents()

        let snapshot = await weather
        let upcomingEvents = await events

        contextTitle = [
            snapshot.city,
            snapshot.temperature.map { "\($0.formatted(.number.precision(.fractionLength(0))))°" },
        ]
        .compactMap { $0 }
        .joined(separator: " · ")

        if let nextEvent = upcomingEvents.first {
            contextSubtitle = "\(nextEvent.title) at \(nextEvent.timeLabel)"
        } else {
            contextSubtitle = "No calendar events yet. Dress for a flexible day."
        }

        refreshReasoning()
    }

    func selectItem(in row: SwipeRowState.ID, index: Int) {
        guard let rowIndex = rows.firstIndex(where: { $0.id == row }),
              rows[rowIndex].items.indices.contains(index) else {
            return
        }

        rows[rowIndex].activeIndex = index
        wearHistoryCount += 1
        refreshReasoning()
    }

    private func refreshReasoning() {
        let shirt = rows[safe: 0]?.activeItem.title ?? "shirt"
        let trouser = rows[safe: 1]?.activeItem.title ?? "trouser"
        let shoe = rows[safe: 2]?.activeItem.title ?? "shoe"
        reasoningLine = "AI suggests \(shirt), \(trouser), and \(shoe) for a lighter, versatile day."
    }

    private static let defaultRows: [SwipeRowState] = [
        SwipeRowState(
            title: "Top",
            subtitle: "Swipe to change the shirt",
            items: [
                HomeOutfitCard(assetName: "shirt_white", title: "White Oxford", note: "Clean base"),
                HomeOutfitCard(assetName: "shirt_blue", title: "Blue Poplin", note: "Sharper tone"),
                HomeOutfitCard(assetName: "shirt_striped", title: "Striped Shirt", note: "More texture"),
                HomeOutfitCard(assetName: "shirt_grey", title: "Grey Shirt", note: "Muted option"),
            ]
        ),
        SwipeRowState(
            title: "Bottom",
            subtitle: "Balance structure and comfort",
            items: [
                HomeOutfitCard(assetName: "trousers_dark", title: "Dark Trouser", note: "Formal edge"),
                HomeOutfitCard(assetName: "trousers_chino", title: "Chino Trouser", note: "Daily staple"),
                HomeOutfitCard(assetName: "trousers_linen", title: "Linen Trouser", note: "Airier pick"),
            ]
        ),
        SwipeRowState(
            title: "Shoes",
            subtitle: "Finish the look",
            items: [
                HomeOutfitCard(assetName: "shoes_derby", title: "Derby", note: "Boardroom ready"),
                HomeOutfitCard(assetName: "shoes_loafer", title: "Loafer", note: "Relaxed smart"),
                HomeOutfitCard(assetName: "shoes_sneaker_white", title: "White Sneaker", note: "Casual reset"),
            ]
        ),
    ]
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
