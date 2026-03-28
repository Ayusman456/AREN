import Combine
import Foundation

@MainActor
final class EventsViewModel: ObservableObject {
    @Published private(set) var events: [CalendarEvent] = []

    private let calendarService: CalendarService
    private var hasLoaded = false

    init(calendarService: CalendarService? = nil) {
        self.calendarService = calendarService ?? CalendarService()
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        events = await calendarService.fetchUpcomingEvents()
    }
}
