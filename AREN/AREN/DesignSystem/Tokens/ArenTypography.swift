import SwiftUI

enum ArenTypographyToken: CaseIterable {
    case wardrobeNavActive
    case wardrobeNavInactive
    case wardrobeCTA
    case wardrobeEmptyTitle
    case wardrobeEmptyBody
    case wardrobeProductStatus
    case wardrobeProductMeta
}

struct ArenTextStyle {
    let fontName: String
    let size: CGFloat
    let lineHeight: CGFloat
    let tracking: CGFloat

    var font: Font {
        .custom(fontName, size: size)
    }
}

enum ArenTypography {
    private static let helveticaNowTextLight = "HelveticaNowText-Light"
    private static let helveticaNowTextMedium = "HelveticaNowText-Medium"

    static func style(for token: ArenTypographyToken) -> ArenTextStyle {
        switch token {
        case .wardrobeNavActive:
            return .init(
                fontName: helveticaNowTextMedium,
                size: 13,
                lineHeight: 16,
                tracking: 0
            )
        case .wardrobeNavInactive:
            return .init(
                fontName: helveticaNowTextLight,
                size: 13,
                lineHeight: 16,
                tracking: 0
            )
        case .wardrobeCTA:
            return .init(
                fontName: helveticaNowTextLight,
                size: 13,
                lineHeight: 16,
                tracking: 0
            )
        case .wardrobeEmptyTitle:
            return .init(
                fontName: helveticaNowTextLight,
                size: 12,
                lineHeight: 16,
                tracking: 0
            )
        case .wardrobeEmptyBody:
            return .init(
                fontName: helveticaNowTextLight,
                size: 12,
                lineHeight: 18,
                tracking: 0
            )
        case .wardrobeProductStatus:
            return .init(
                fontName: helveticaNowTextLight,
                size: 10,
                lineHeight: 16,
                tracking: 0
            )
        case .wardrobeProductMeta:
            return .init(
                fontName: helveticaNowTextLight,
                size: 11,
                lineHeight: 16,
                tracking: 0
            )
        }
    }
}

struct ArenTypographyModifier: ViewModifier {
    private let style: ArenTextStyle

    init(style: ArenTextStyle) {
        self.style = style
    }

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.tracking)
    }
}

extension View {
    func arenTypography(_ token: ArenTypographyToken) -> some View {
        modifier(ArenTypographyModifier(style: ArenTypography.style(for: token)))
    }

    func arenBodyLeading(size: CGFloat, lineHeight: CGFloat) -> some View {
        let verticalPadding = max(0, (lineHeight - size) / 2)
        return padding(.vertical, verticalPadding)
    }
}

extension String {
    var arenUppercasedDisplay: String {
        uppercased()
    }
}
