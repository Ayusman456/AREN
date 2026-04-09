import SwiftUI
import UIKit

struct DayDetailModalView: View {
    private enum Layout {
        static let sheetWidth: CGFloat = 402
        static let filledSheetHeight: CGFloat = 348
        static let emptySheetHeight: CGFloat = 372
        static let outerVerticalPadding: CGFloat = 20
        static let horizontalInset: CGFloat = 20
        static let stackGap: CGFloat = 20
        static let contentWidth: CGFloat = 362
        static let dayHeaderGap: CGFloat = 4
        static let dayLabelTrailingInset: CGFloat = 20
        static let eventListGap: CGFloat = 20
        static let eventRowHeight: CGFloat = 32
        static let eventRowGap: CGFloat = 8
        static let eventTitleTrailingPadding: CGFloat = 2
        static let eventTimeHorizontalPadding: CGFloat = 4
        static let tagOuterPadding: CGFloat = 6
        static let tagInnerHorizontalPadding: CGFloat = 4
        static let footerTopPadding: CGFloat = 20
        static let buttonHeight: CGFloat = 32
        static let buttonBorderWidth: CGFloat = 0.7
        static let emptyStateVerticalPadding: CGFloat = 48
        static let emptyStateHorizontalPadding: CGFloat = 20
        static let emptyStateGap: CGFloat = 12
        static let emptyMessageWidth: CGFloat = 240
    }

    struct ScheduleEvent: Identifiable, Hashable {
        let id: UUID
        let title: String
        let timeText: String
        let occasion: String

        init(
            id: UUID = UUID(),
            title: String,
            timeText: String,
            occasion: String
        ) {
            self.id = id
            self.title = title
            self.timeText = timeText
            self.occasion = occasion
        }
    }

    let date: Date
    let events: [ScheduleEvent]
    @Binding var isAddingEvent: Bool
    let onSelectEvent: (ScheduleEvent) -> Void
    let onTapOccasion: (ScheduleEvent) -> Void

    init(
        date: Date,
        events: [ScheduleEvent] = [],
        isAddingEvent: Binding<Bool>,
        onSelectEvent: @escaping (ScheduleEvent) -> Void = { _ in },
        onTapOccasion: @escaping (ScheduleEvent) -> Void = { _ in }
    ) {
        self.date = date
        self.events = events
        self._isAddingEvent = isAddingEvent
        self.onSelectEvent = onSelectEvent
        self.onTapOccasion = onTapOccasion
    }

    var body: some View {
        VStack(spacing: Layout.stackGap) {
            content
            footer
        }
        .padding(.vertical, Layout.outerVerticalPadding)
        .frame(width: Layout.sheetWidth, height: sheetHeight, alignment: .top)
        .background(ArenColor.Surface.primary)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            bodyContent
        }
        .padding(.horizontal, Layout.horizontalInset)
        .frame(width: Layout.sheetWidth, alignment: .topLeading)
    }

    private var bodyContent: some View {
        VStack(alignment: .leading, spacing: Layout.stackGap) {
            dateHeader

            if events.isEmpty {
                emptyState
            } else {
                eventList
            }
        }
        .frame(width: Layout.contentWidth, alignment: .topLeading)
    }

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: Layout.dayHeaderGap) {
            Text(dayLabelText)
                .font(Self.dayLabelFont)
                .foregroundStyle(ArenColor.Text.primary)
                .textCase(.uppercase)
                .figmaLineHeight(16)
                .padding(.trailing, Layout.dayLabelTrailingInset)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(dateNumberText)
                .font(Self.dateNumberFont)
                .foregroundStyle(ArenColor.Text.primary)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var eventList: some View {
        VStack(alignment: .leading, spacing: Layout.eventListGap) {
            ForEach(events) { event in
                eventRow(event)
            }
        }
        .frame(width: Layout.contentWidth, alignment: .topLeading)
    }

    private func eventRow(_ event: ScheduleEvent) -> some View {
        HStack(spacing: Layout.eventRowGap) {
            Button(action: { onSelectEvent(event) }) {
                Text(event.title)
                    .font(Self.eventTextFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .textCase(.uppercase)
                    .figmaLineHeight(16)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.trailing, Layout.eventTitleTrailingPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text(event.timeText)
                .font(Self.eventTextFont)
                .foregroundStyle(ArenColor.Text.primary)
                .figmaLineHeight(16)
                .lineLimit(1)
                .padding(.horizontal, Layout.eventTimeHorizontalPadding)
                .fixedSize(horizontal: true, vertical: false)

            Spacer(minLength: 0)

            Button(action: { onTapOccasion(event) }) {
                Text(event.occasion)
                    .font(Self.eventTextFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .textCase(.uppercase)
                    .figmaLineHeight(16)
                    .lineLimit(1)
                    .padding(Layout.tagOuterPadding)
                    .padding(.horizontal, Layout.tagInnerHorizontalPadding)
                    .background(ArenColor.Fill.tertiary)
            }
            .buttonStyle(.plain)
            .fixedSize(horizontal: true, vertical: false)
        }
        .frame(width: Layout.contentWidth, height: Layout.eventRowHeight, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: Layout.emptyStateGap) {
            Text("No Events Added")
                .font(Self.emptyTitleFont)
                .foregroundStyle(ArenColor.Text.primary)
                .textCase(.uppercase)
                .figmaLineHeight(16)
                .lineLimit(1)

            Text("Add an event to define the day and generate a more accurate look.")
                .font(Self.emptyBodyFont)
                .foregroundStyle(ArenColor.Text.primary)
                .figmaLineHeight(18)
                .multilineTextAlignment(.center)
                .frame(width: Layout.emptyMessageWidth)
        }
        .padding(.horizontal, Layout.emptyStateHorizontalPadding)
        .padding(.vertical, Layout.emptyStateVerticalPadding)
        .frame(width: Layout.contentWidth, alignment: .center)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { isAddingEvent = true }) {
                Text("Add Event")
                    .font(Self.buttonLabelFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .textCase(.uppercase)
                    .figmaLineHeight(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(width: Layout.contentWidth, height: Layout.buttonHeight)
            .overlay(
                Rectangle()
                    .stroke(ArenColor.Icon.primary, lineWidth: Layout.buttonBorderWidth)
            )
        }
        .padding(.top, Layout.footerTopPadding)
        .padding(.horizontal, Layout.horizontalInset)
        .frame(width: Layout.sheetWidth, alignment: .topLeading)
    }

    private var sheetHeight: CGFloat {
        events.isEmpty ? Layout.emptySheetHeight : Layout.filledSheetHeight
    }

    private var dayLabelText: String {
        Self.dayFormatter.string(from: date)
    }

    private var dateNumberText: String {
        Self.dateNumberFormatter.string(from: date)
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    private static let dateNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d"
        return formatter
    }()

    private static func helveticaNow(size: CGFloat) -> Font {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular",
        ]

        for name in candidates where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }

        return .system(size: size, weight: .light)
    }

    private static let dayLabelFont: Font = helveticaNow(size: 11)
    private static let eventTextFont: Font = helveticaNow(size: 11)
    private static let emptyTitleFont: Font = helveticaNow(size: 12)
    private static let emptyBodyFont: Font = helveticaNow(size: 12)
    private static let buttonLabelFont: Font = helveticaNow(size: 13)
    private static let dateNumberFont: Font = helveticaNow(size: 40)
}

private extension View {
    func figmaLineHeight(_ lineHeight: CGFloat) -> some View {
        frame(minHeight: lineHeight, alignment: .center)
    }
}

#Preview("Filled") {
    DayDetailModalPreviewContainer(
        events: [
            .init(title: "Client Lunch", timeText: "1:00 PM", occasion: "Business Casual"),
            .init(title: "Team Standup", timeText: "3:00 PM", occasion: "Business"),
            .init(title: "Dinner with Sara", timeText: "7:30 PM", occasion: "Evening"),
        ]
    )
}

#Preview("Empty") {
    DayDetailModalPreviewContainer(events: [])
}

private struct DayDetailModalPreviewContainer: View {
    @State private var isAddingEvent = false
    let events: [DayDetailModalView.ScheduleEvent]

    var body: some View {
        DayDetailModalView(
            date: Self.previewDate,
            events: events,
            isAddingEvent: $isAddingEvent
        )
        .background(ArenColor.Surface.primary)
    }

    private static let previewDate: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 4
        components.day = 24
        return Calendar(identifier: .gregorian).date(from: components) ?? .now
    }()
}
