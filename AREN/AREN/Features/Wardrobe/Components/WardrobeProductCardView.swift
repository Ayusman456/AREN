import SwiftUI
import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") { sanitized.removeFirst() }

        guard sanitized.count == 6, let rgb = UInt64(sanitized, radix: 16) else {
            return nil
        }

        self.init(
            red:   CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8)  & 0xFF) / 255,
            blue:  CGFloat( rgb        & 0xFF) / 255,
            alpha: 1
        )
    }
}
struct WardrobeProductCardView: View {
    let imageAssetName: String
    let titleText: String
    let priceText: String?
    let coloursText: String?
    let colourSwatchHex: String?
    let showsAddButton: Bool
    let onAddTap: (() -> Void)?

    init(
        imageAssetName: String,
        titleText: String,
        priceText: String? = nil,
        coloursText: String? = nil,
        colourSwatchHex: String? = nil,
        showsAddButton: Bool = true,
        onAddTap: (() -> Void)? = nil
    ) {
        self.imageAssetName = imageAssetName
        self.titleText = titleText
        self.priceText = priceText
        self.coloursText = coloursText
        self.colourSwatchHex = colourSwatchHex
        self.showsAddButton = showsAddButton
        self.onAddTap = onAddTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            imageArea
            detailsArea
        }
        .frame(maxWidth: .infinity, alignment: .top)
         .border(Color.pink)  // debug purpose
        .background(ArenColor.Surface.primary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    // MARK: - Subviews

    private var imageArea: some View {
        Image(imageAssetName)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(height: 257)
            .border(Color.blue)  // testing purpose
            .clipped()
    }

    private var detailsArea: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleRow

            if let priceText {
                Text(priceText.uppercased())
                    .font(Self.priceFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .lineLimit(1)
            }

            if let coloursText {
                coloursRow(text: coloursText)
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private var titleRow: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(titleText.uppercased())
                .font(Self.titleFont)
                .foregroundStyle(ArenColor.Text.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            if showsAddButton {
                Button(action: onAddTap ?? {}) {
                    Image("Plus")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(ArenColor.Icon.primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add \(titleText) to wardrobe")
            }
        }
    }

    private func coloursRow(text: String) -> some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(Self.swatchFill(for: colourSwatchHex))
                .overlay(
                    Rectangle()
                        .stroke(ArenColor.Border.primary, lineWidth: 1)
                )
                .frame(width: 10, height: 10)

            Text(text)
                .font(Self.coloursFont)
                .foregroundStyle(ArenColor.Text.primary)
                .lineLimit(1)
        }
    }

    // MARK: - Accessibility

    private var accessibilitySummary: String {
        var parts = [titleText]
        if let priceText { parts.append(priceText) }
        if let coloursText { parts.append(coloursText) }
        return parts.joined(separator: ", ")
    }

    // MARK: - Swatch

    private static func swatchFill(for hex: String?) -> Color {
        guard let hex, let uiColor = UIColor(hex: hex) else {
            return Color(red: 168 / 255, green: 183 / 255, blue: 187 / 255)
        }
        return Color(uiColor: uiColor)
    }

    // MARK: - Typography

    private static let resolvedFontName: String = {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular"
        ]
        return candidates.first { UIFont(name: $0, size: 11) != nil } ?? ""
    }()

    private static var titleFont: Font {
        customFont(size: 11, relativeTo: .caption)
    }

    private static var priceFont: Font {
        customFont(size: 11, relativeTo: .caption)
    }

    private static var coloursFont: Font {
        customFont(size: 10, relativeTo: .caption2)
    }

    private static func customFont(size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        guard !resolvedFontName.isEmpty else {
            return .system(size: size, weight: .light, design: .default)
        }
        return .custom(resolvedFontName, size: size, relativeTo: textStyle)
    }
}

// MARK: - Previews

#Preview("Full — with price, colours, swatch") {
    WardrobeProductCardView(
        imageAssetName: "preview_placeholder",   // replace with any asset in your catalogue
        titleText: "Linen Blazer",
        priceText: "£195.00",
        coloursText: "3 colours",
        colourSwatchHex: "#C8A882",
        showsAddButton: true,
        onAddTap: { print("Add tapped") }
    )
    .frame(width: 171)
    .padding()
}

#Preview("Minimal — title only, no add button") {
    WardrobeProductCardView(
        imageAssetName: "preview_placeholder",
        titleText: "Cotton Tee",
        showsAddButton: false
    )
    .frame(width: 171)
    .padding()
}

#Preview("Grid layout") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            WardrobeProductCardView(
                imageAssetName: "preview_placeholder",
                titleText: "Slim Trousers",
                priceText: "£89.00",
                coloursText: "5 colours",
                colourSwatchHex: "#2C3E50",
                onAddTap: { print("Add tapped") }
            )
            WardrobeProductCardView(
                imageAssetName: "preview_placeholder",
                titleText: "Merino Knit",
                priceText: "£145.00",
                coloursText: "2 colours",
                colourSwatchHex: "#8B4513",
                onAddTap: { print("Add tapped") }
            )
            WardrobeProductCardView(
                imageAssetName: "preview_placeholder",
                titleText: "Silk Blouse",
                priceText: "£220.00",
                coloursText: "1 colour",
                colourSwatchHex: "#F5F5DC",
                onAddTap: { print("Add tapped") }
            )
            WardrobeProductCardView(
                imageAssetName: "preview_placeholder",
                titleText: "Denim Jacket",
                priceText: "£175.00",
                coloursText: "2 colours",
                colourSwatchHex: "#4169E1",
                onAddTap: { print("Add tapped") }
            )
        }
        .padding()
    }
}
