import SwiftUI
import UIKit

struct DemoBannerCTAView: View {
    let titleText: String
    let statusText: String
    let onTap: (() -> Void)?

    init(
        titleText: String = "DEMO WARDROBE",
        statusText: String = "12 PIECES READY",
        onTap: (() -> Void)? = nil
    ) {
        self.titleText = titleText
        self.statusText = statusText
        self.onTap = onTap
    }

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(titleText)
                        .font(Self.titleFont)
                        .foregroundStyle(ArenColor.Text.inverse)
                        .lineLimit(1)
                        .textCase(.uppercase)
                        .frame(height: 16, alignment: .center)

                    Text(statusText)
                        .font(Self.statusFont)
                        .foregroundStyle(ArenColor.Text.inverse)
                        .lineLimit(1)
                        .textCase(.uppercase)
                        .frame(height: 16, alignment: .center)
                }
                .frame(width: 116, alignment: .leading)

                Spacer(minLength: 0)

                Image("demo_banner_chevron")
                    .resizable()
                    .renderingMode(.template)
                    .interpolation(.high)
                    .antialiased(true)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .foregroundStyle(ArenColor.Text.inverse)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .frame(width: 402)
            .background(ArenColor.Fill.primary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(titleText), \(statusText)")
    }

    private static var titleFont: Font {
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

    private static var statusFont: Font {
        let candidates = [
            "HelveticaNowText-Medium",
            "HelveticaNowText Medium",
            "HelveticaNowText-Regular",
        ]

        for name in candidates where UIFont(name: name, size: 12) != nil {
            return .custom(name, size: 12)
        }

        return .system(size: 12, weight: .medium)
    }
}

#Preview {
    DemoBannerCTAView(onTap: {})
        .frame(width: 402)
        .background(ArenColor.Surface.primary)
}
