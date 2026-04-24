import SwiftUI
import UIKit

// MARK: - Model

enum ScheduleRowState: Hashable {
    case withDate
    case noDate
    case longTitleSafe
}

// MARK: - View

struct ScheduleRowView: View {

    let state: ScheduleRowState
    let dateText: String
    let titleText: String
    let timeText: String
    let showsCTA: Bool
    let ctaTitle: String
    let onCTATap: (() -> Void)?
    let overflowCount: Int?
    let onOverflowTap: (() -> Void)?

    // MARK: - Init

    init(
        state: ScheduleRowState = .withDate,
        dateText: String = "SAT 21",
        titleText: String = "CLIENT LUNCH",
        timeText: String = "1:00 PM",
        showsCTA: Bool = false,
        ctaTitle: String = "JOIN/SIGN IN",
        onCTATap: (() -> Void)? = nil,
        overflowCount: Int? = nil,
        onOverflowTap: (() -> Void)? = nil
    ) {
        self.state = state
        self.dateText = dateText
        self.titleText = titleText
        self.timeText = timeText
        self.showsCTA = showsCTA
        self.ctaTitle = ctaTitle
        self.onCTATap = onCTATap
        self.overflowCount = overflowCount
        self.onOverflowTap = onOverflowTap
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            switch state {
            case .noDate:
                noDateRow
            case .withDate, .longTitleSafe:
                withDateRow
            }
        }
        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .leading)
        .padding(.horizontal, 20)
        .background(ArenColor.Surface.primary)
    }

    // MARK: - Row Variants

    @ViewBuilder
    private var noDateRow: some View {
        label(titleText, color: ArenColor.Text.primary)
        label(timeText, color: ArenColor.Text.primary, horizontalPadding: 4)
    }

    @ViewBuilder
    private var withDateRow: some View {
        label(dateText, color: ArenColor.Text.secondary, trailingPadding: 6)

        divider

        label(
            titleText,
            color: ArenColor.Text.primary,
            trailingPadding: 2,
            horizontalPadding: 4,
            expands: state == .longTitleSafe
        )

        label(timeText, color: ArenColor.Text.primary, horizontalPadding: 4)

        if let count = overflowCount, count > 0 {
            divider
                .padding(.leading, 6)
            overflowButton(count)
        } else if showsCTA {
            Spacer(minLength: 0)
            ctaButton
        }
    }

    // MARK: - Subviews

    private var divider: some View {
        Rectangle()
            .fill(ArenColor.Fill.tertiary)
            .frame(width: 1, height: 16)
    }

    private func label(
        _ text: String,
        color: Color,
        trailingPadding: CGFloat = 0,
        horizontalPadding: CGFloat = 0,
        expands: Bool = false
    ) -> some View {
        Text(text)
            .font(Self.scheduleFont)
            .foregroundStyle(color)
            .textCase(.uppercase)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, horizontalPadding)
            .padding(.trailing, trailingPadding)
            .frame(maxWidth: expands ? .infinity : nil, minHeight: 16, alignment: .leading)
    }

    private func overflowButton(_ count: Int) -> some View {
        Button(action: { onOverflowTap?() }) {
            Text("+\(count) MORE")
                .font(Self.scheduleFont)
                .foregroundStyle(ArenColor.Text.secondary)
                .textCase(.uppercase)
                .lineLimit(1)
                .padding(.leading, 6)
        }
        .buttonStyle(.plain)
    }

    private var ctaButton: some View {
        Button(action: { onCTATap?() }) {
            Text(ctaTitle)
                .font(Self.scheduleFont)
                .foregroundStyle(ArenColor.Text.inverse)
                .textCase(.uppercase)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .frame(minHeight: 28)
                .background(ArenColor.Fill.primary)
        }
        .buttonStyle(.plain)
        .disabled(onCTATap == nil)
    }

    // MARK: - Fonts
    // TODO: Replace with direct font values once design system is finalised

    private static func helveticaNow(size: CGFloat) -> Font {
        let candidates = ["HelveticaNowText-Light", "HelveticaNowText-Regular"]
        for name in candidates where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: .light)
    }

    private static let scheduleFont: Font = helveticaNow(size: 13)
}

// MARK: - Previews
// Preview width 402pt = iPhone 16 Pro screen width minus safe area insets

#Preview("With Date") {
    ScheduleRowView()
        .frame(width: 402)
        .background(ArenColor.Surface.primary)
}

#Preview("No Date") {
    ScheduleRowView(
        state: .noDate,
        titleText: "CLIENT LUNCH",
        timeText: "1:00 PM"
    )
    .frame(width: 402)
    .background(ArenColor.Surface.primary)
}

#Preview("Long Title") {
    ScheduleRowView(
        state: .longTitleSafe,
        titleText: "QUARTERLY STRATEGY WORKSHOP WITH CLIENT TEAM",
        timeText: "10:30 AM"
    )
    .frame(width: 402)
    .background(ArenColor.Surface.primary)
}

#Preview("With CTA") {
    ScheduleRowView(
        showsCTA: true,
        onCTATap: {}
    )
    .frame(width: 402)
    .background(ArenColor.Surface.primary)
}

#Preview("With Overflow") {
    ScheduleRowView(
        dateText: "SAT 21",
        titleText: "CLIENT LUNCH",
        timeText: "1:00 PM",
        overflowCount: 2,
        onOverflowTap: {}
    )
    .frame(width: 402)
    .background(ArenColor.Surface.primary)
}
