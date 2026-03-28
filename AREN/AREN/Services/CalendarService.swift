import Foundation

struct CalendarService {
    func fetchUpcomingEvents(now: Date = .now) async -> [CalendarEvent] {
        try? await Task.sleep(for: .milliseconds(80))

        let calendar = Calendar.current

        return [
            CalendarEvent(
                title: "Studio review",
                startDate: calendar.date(byAdding: .hour, value: 2, to: now) ?? now,
                location: "Indiranagar"
            ),
            CalendarEvent(
                title: "Dinner reservation",
                startDate: calendar.date(byAdding: .hour, value: 8, to: now) ?? now,
                location: "MG Road"
            ),
        ]
    }
}
