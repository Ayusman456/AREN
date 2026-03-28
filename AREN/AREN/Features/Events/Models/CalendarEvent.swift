import Foundation

struct CalendarEvent: Identifiable, Hashable, Sendable {
    let id = UUID()
    let title: String
    let startDate: Date
    let location: String?

    var timeLabel: String {
        startDate.formatted(date: .omitted, time: .shortened)
    }
}
