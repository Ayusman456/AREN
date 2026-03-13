import SwiftUI
import UIKit
import CoreText

private enum ArenFontRegistrar {
    private static var hasRegistered = false

    static func registerIfNeeded(bundle: Bundle = .main) {
        guard !hasRegistered else { return }
        hasRegistered = true

        let fontFiles = [
            "Geist-Regular.ttf",
            "Geist-Medium.ttf",
            "Geist-SemiBold.ttf",
            "Geist-Bold.ttf",
        ]

        for file in fontFiles {
            let parts = file.split(separator: ".", maxSplits: 1).map(String.init)
            guard parts.count == 2,
                  let url = bundle.url(forResource: parts[0], withExtension: parts[1]) else {
                continue
            }

            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

private func arenDebugFontWarning(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}

enum ArenWeight {
    case regular
    case medium
    case semiBold
    case bold
}

enum ArenTextRole {
    case caption
    case footnote
    case subheadline
    case body
    case headline
    case title
    case largeTitle
}

enum ArenFontFamily {
    static let regular = ["Geist-Regular", "GeistRoman-Regular", "Geist"]
    static let medium = ["Geist-Medium", "GeistRoman-Medium"]
    static let semiBold = ["Geist-SemiBold", "GeistRoman-SemiBold"]
    static let bold = ["Geist-Bold", "GeistRoman-Bold"]
}

enum ArenFontSize {
    static let caption: CGFloat = 10
    static let footnote: CGFloat = 12
    static let subheadline: CGFloat = 14
    static let body: CGFloat = 16
    static let headline: CGFloat = 20
    static let title: CGFloat = 24
    static let largeTitle: CGFloat = 32
}

enum ArenLineHeight {
    static let caption: CGFloat = 14
    static let footnote: CGFloat = 16
    static let subheadline: CGFloat = 20
    static let body: CGFloat = 24
    static let headline: CGFloat = 30
    static let title: CGFloat = 36
    static let largeTitle: CGFloat = 48
}

enum ArenLetterSpacing {
    static let caption: CGFloat = 0
    static let footnote: CGFloat = 0
    static let subheadline: CGFloat = 0
    static let body: CGFloat = 0
    static let headline: CGFloat = 0
    static let title: CGFloat = 0
    static let largeTitle: CGFloat = 0
}

private extension Font {
    static func arenResolvedFont(
        candidates: [String],
        size: CGFloat,
        relativeTo textStyle: TextStyle,
        fallbackWeight: Font.Weight
    ) -> Font {
        ArenFontRegistrar.registerIfNeeded()

        for name in candidates where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size, relativeTo: textStyle)
        }

        arenDebugFontWarning("ARĒN: Geist font candidates not found: \(candidates.joined(separator: ", ")). Falling back to system font.")
        return .system(size: size, weight: fallbackWeight)
    }

    static func arenFont(role: ArenTextRole, weight: ArenWeight) -> Font {
        let size = arenFontSize(for: role)
        let textStyle = arenRelativeTextStyle(for: role)

        switch role {
        case .caption:
            switch weight {
            case .regular: return arenResolvedFont(candidates: ArenFontFamily.regular, size: size, relativeTo: textStyle, fallbackWeight: .regular)
            case .medium: return arenResolvedFont(candidates: ArenFontFamily.medium, size: size, relativeTo: textStyle, fallbackWeight: .medium)
            case .semiBold: return arenResolvedFont(candidates: ArenFontFamily.semiBold, size: size, relativeTo: textStyle, fallbackWeight: .semibold)
            case .bold: return arenResolvedFont(candidates: ArenFontFamily.bold, size: size, relativeTo: textStyle, fallbackWeight: .bold)
            }
        case .footnote:
            switch weight {
            case .regular: return arenResolvedFont(candidates: ArenFontFamily.regular, size: size, relativeTo: textStyle, fallbackWeight: .regular)
            case .medium: return arenResolvedFont(candidates: ArenFontFamily.medium, size: size, relativeTo: textStyle, fallbackWeight: .medium)
            case .semiBold: return arenResolvedFont(candidates: ArenFontFamily.semiBold, size: size, relativeTo: textStyle, fallbackWeight: .semibold)
            case .bold: return arenResolvedFont(candidates: ArenFontFamily.bold, size: size, relativeTo: textStyle, fallbackWeight: .bold)
            }
        case .subheadline:
            switch weight {
            case .regular: return arenResolvedFont(candidates: ArenFontFamily.regular, size: size, relativeTo: textStyle, fallbackWeight: .regular)
            case .medium: return arenResolvedFont(candidates: ArenFontFamily.medium, size: size, relativeTo: textStyle, fallbackWeight: .medium)
            case .semiBold: return arenResolvedFont(candidates: ArenFontFamily.semiBold, size: size, relativeTo: textStyle, fallbackWeight: .semibold)
            case .bold: return arenResolvedFont(candidates: ArenFontFamily.bold, size: size, relativeTo: textStyle, fallbackWeight: .bold)
            }
        case .body:
            switch weight {
            case .regular: return arenResolvedFont(candidates: ArenFontFamily.regular, size: size, relativeTo: textStyle, fallbackWeight: .regular)
            case .medium: return arenResolvedFont(candidates: ArenFontFamily.medium, size: size, relativeTo: textStyle, fallbackWeight: .medium)
            case .semiBold: return arenResolvedFont(candidates: ArenFontFamily.semiBold, size: size, relativeTo: textStyle, fallbackWeight: .semibold)
            case .bold: return arenResolvedFont(candidates: ArenFontFamily.bold, size: size, relativeTo: textStyle, fallbackWeight: .bold)
            }
        case .headline:
            switch weight {
            case .regular: return arenResolvedFont(candidates: ArenFontFamily.regular, size: size, relativeTo: textStyle, fallbackWeight: .regular)
            case .medium: return arenResolvedFont(candidates: ArenFontFamily.medium, size: size, relativeTo: textStyle, fallbackWeight: .medium)
            case .semiBold: return arenResolvedFont(candidates: ArenFontFamily.semiBold, size: size, relativeTo: textStyle, fallbackWeight: .semibold)
            case .bold: return arenResolvedFont(candidates: ArenFontFamily.bold, size: size, relativeTo: textStyle, fallbackWeight: .bold)
            }
        case .title:
            switch weight {
            case .regular: return arenResolvedFont(candidates: ArenFontFamily.regular, size: size, relativeTo: textStyle, fallbackWeight: .regular)
            case .medium: return arenResolvedFont(candidates: ArenFontFamily.medium, size: size, relativeTo: textStyle, fallbackWeight: .medium)
            case .semiBold: return arenResolvedFont(candidates: ArenFontFamily.semiBold, size: size, relativeTo: textStyle, fallbackWeight: .semibold)
            case .bold: return arenResolvedFont(candidates: ArenFontFamily.bold, size: size, relativeTo: textStyle, fallbackWeight: .bold)
            }
        case .largeTitle:
            switch weight {
            case .regular: return arenResolvedFont(candidates: ArenFontFamily.regular, size: size, relativeTo: textStyle, fallbackWeight: .regular)
            case .medium: return arenResolvedFont(candidates: ArenFontFamily.medium, size: size, relativeTo: textStyle, fallbackWeight: .medium)
            case .semiBold: return arenResolvedFont(candidates: ArenFontFamily.semiBold, size: size, relativeTo: textStyle, fallbackWeight: .semibold)
            case .bold: return arenResolvedFont(candidates: ArenFontFamily.bold, size: size, relativeTo: textStyle, fallbackWeight: .bold)
            }
        }
    }
}

private func arenFontSize(for role: ArenTextRole) -> CGFloat {
    switch role {
    case .caption: return ArenFontSize.caption
    case .footnote: return ArenFontSize.footnote
    case .subheadline: return ArenFontSize.subheadline
    case .body: return ArenFontSize.body
    case .headline: return ArenFontSize.headline
    case .title: return ArenFontSize.title
    case .largeTitle: return ArenFontSize.largeTitle
    }
}

private func arenLineHeight(for role: ArenTextRole) -> CGFloat {
    switch role {
    case .caption: return ArenLineHeight.caption
    case .footnote: return ArenLineHeight.footnote
    case .subheadline: return ArenLineHeight.subheadline
    case .body: return ArenLineHeight.body
    case .headline: return ArenLineHeight.headline
    case .title: return ArenLineHeight.title
    case .largeTitle: return ArenLineHeight.largeTitle
    }
}

private func arenTracking(for role: ArenTextRole) -> CGFloat {
    switch role {
    case .caption: return ArenLetterSpacing.caption
    case .footnote: return ArenLetterSpacing.footnote
    case .subheadline: return ArenLetterSpacing.subheadline
    case .body: return ArenLetterSpacing.body
    case .headline: return ArenLetterSpacing.headline
    case .title: return ArenLetterSpacing.title
    case .largeTitle: return ArenLetterSpacing.largeTitle
    }
}

private func arenRelativeTextStyle(for role: ArenTextRole) -> Font.TextStyle {
    switch role {
    case .caption: return .caption
    case .footnote: return .footnote
    case .subheadline: return .subheadline
    case .body: return .body
    case .headline: return .headline
    case .title: return .title
    case .largeTitle: return .largeTitle
    }
}

struct ArenTextStyle: ViewModifier {
    let role: ArenTextRole
    let weight: ArenWeight

    func body(content: Content) -> some View {
        let size = arenFontSize(for: role)
        let lineHeight = arenLineHeight(for: role)
        let tracking = arenTracking(for: role)

        return content
            .font(.arenFont(role: role, weight: weight))
            .lineSpacing(max(0, lineHeight - size))
            .tracking(tracking)
    }
}

extension View {
    func arenText(_ role: ArenTextRole, weight: ArenWeight = .regular) -> some View {
        modifier(ArenTextStyle(role: role, weight: weight))
    }
}
