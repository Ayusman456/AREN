import SwiftUI
import UIKit

enum ScheduleRowState: Hashable {
    case withDate
    case noDate
    case longTitleSafe
}

struct ScheduleRowView: View {
    let state: ScheduleRowState
    let dateText: String
    let titleText: String
    let timeText: String
    let showsCTA: Bool
    let ctaTitle: String
    let onCTATap: (() -> Void)?

    init(
        state: ScheduleRowState = .withDate,
        dateText: String = "SAT 21",
        titleText: String = "CLIENT LUNCH",
        timeText: String = "1:00 PM",
        showsCTA: Bool = false,
        ctaTitle: String = "JOIN/SIGN IN",
        onCTATap: (() -> Void)? = nil
    ) {
        self.state = state
        self.dateText = dateText
        self.titleText = titleText
        self.timeText = timeText
        self.showsCTA = showsCTA
        self.ctaTitle = ctaTitle
        self.onCTATap = onCTATap
    }

    var body: some View {
        HStack(spacing: 0) {
            if state == .noDate {
                rowLabel(
                    titleText,
                    color: ArenColor.Text.primary,
                    trailingPadding: 2,
                    horizontalPadding: 0
                )
                rowLabel(timeText, color: ArenColor.Text.primary, horizontalPadding: 4)
            } else {
                rowLabel(
                    dateText,
                    color: ArenColor.Text.secondary,
                    trailingPadding: 6,
                    horizontalPadding: 0
                )

                Rectangle()
                    .fill(ArenColor.Fill.tertiary)
                    .frame(width: 1, height: 16)

                if state == .longTitleSafe {
                    rowLabel(
                        titleText,
                        color: ArenColor.Text.primary,
                        trailingPadding: 2,
                        horizontalPadding: 4,
                        expands: true
                    )
                    rowLabel(timeText, color: ArenColor.Text.primary, horizontalPadding: 4)
                    Color.clear
                        .frame(width: 8, height: 1)
                } else {
                    rowLabel(
                        titleText,
                        color: ArenColor.Text.primary,
                        trailingPadding: 2,
                        horizontalPadding: 4
                    )
                    rowLabel(timeText, color: ArenColor.Text.primary, horizontalPadding: 4)

                    if showsCTA {
                        Spacer(minLength: 0)
                        ctaButton
                    } else {
                        Color.clear
                            .frame(width: 1, height: 1)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .leading)
        .padding(.horizontal, 20)
        .background(ArenColor.Surface.primary)
    }

    private func rowLabel(
        _ text: String,
        color: Color,
        trailingPadding: CGFloat = 0,
        horizontalPadding: CGFloat = 4,
        expands: Bool = false
    ) -> some View {
        HStack(spacing: 0) {
            Text(text)
                .font(Self.scheduleFont)
                .foregroundStyle(color)
                .lineSpacing(4)
                .textCase(.uppercase)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: expands ? .infinity : nil, alignment: .center)
                .padding(.horizontal, horizontalPadding)
        }
        .padding(.trailing, trailingPadding)
        .frame(maxWidth: expands ? .infinity : nil, alignment: .leading)
    }

    private var ctaButton: some View {
        Button(action: { onCTATap?() }) {
            Text(ctaTitle)
                .font(Self.ctaFont)
                .foregroundStyle(ArenColor.Text.inverse)
                .lineSpacing(4)
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

    private static var scheduleFont: Font {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular",
            "HelveticaNowText-Regular",
        ]

        for name in candidates where UIFont(name: name, size: 13) != nil {
            return .custom(name, size: 13)
        }

        return .system(size: 13, weight: .light)
    }

    private static var ctaFont: Font {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular",
        ]

        for name in candidates where UIFont(name: name, size: 12) != nil {
            return .custom(name, size: 12)
        }

        return .system(size: 12, weight: .light)
    }
}

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

#Preview("Long Title Safe") {
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
