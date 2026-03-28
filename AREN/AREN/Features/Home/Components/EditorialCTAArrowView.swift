import SwiftUI
import UIKit

struct EditorialCTAArrowView: View {
    let titleText: String
    let subtitleText: String
    let onTap: (() -> Void)?

    init(
        titleText: String = "This Is An Example Of A Wardrobe",
        subtitleText: String = "Wanna Play With Yours Own Clothes ?",
        onTap: (() -> Void)? = nil
    ) {
        self.titleText = titleText
        self.subtitleText = subtitleText
        self.onTap = onTap
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(titleText)
                    .font(Self.titleFont)
                    .foregroundStyle(ArenColor.Text.inverse)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(subtitleText)
                    .font(Self.subtitleFont)
                    .foregroundStyle(ArenColor.Text.inverse)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 195, alignment: .leading)

            Spacer(minLength: 0)

            Button(action: { onTap?() }) {
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 38, height: 38)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(ArenColor.Icon.primary)
                        .offset(x: 1)
                }
            }
            .buttonStyle(.plain)
            .disabled(onTap == nil)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .frame(width: 402, height: 47)
        .background(ArenColor.Fill.primary)
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

    private static var subtitleFont: Font {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular",
        ]

        for name in candidates where UIFont(name: name, size: 9) != nil {
            return .custom(name, size: 9)
        }

        return .system(size: 9, weight: .light)
    }
}

#Preview {
    EditorialCTAArrowView()
        .background(ArenColor.Surface.primary)
}
