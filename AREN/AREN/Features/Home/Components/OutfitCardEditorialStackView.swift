import SwiftUI
import UIKit

// MARK: - Debug Border Extension

extension View {
    @ViewBuilder
    func debugBorder(if show: Bool, color: Color = .red, width: CGFloat = 2) -> some View {
        if show {
            self.border(color, width: width)
        } else {
            self
        }
    }
}

// MARK: - Model

struct OutfitCategory {
    let items: [String]

    init(items: [String]) {
        self.items = items
    }
}

// MARK: - View

struct OutfitCardEditorialStackView: View {

    // Toggle to show/hide all debug borders
    private let showDebugBorders = false

    @State private var topsIndex: Int = 0
    @State private var bottomsIndex: Int = 0
    @State private var shoesIndex: Int = 0

    let tops: OutfitCategory
    let bottoms: OutfitCategory
    let shoes: OutfitCategory
    let captionText: String

    // MARK: - Layout Constants

    private enum Layout {
        static let canvasWidth: CGFloat = 280       // Outfit canvas — locked to Figma spec
        static let garmentWidth: CGFloat = 257      // Garment image width — locked to Figma spec
        static let topsHeight: CGFloat = 216        // Tops row height — locked to Figma spec
        static let bottomsHeight: CGFloat = 246     // Bottoms row height — locked to Figma spec
        static let shoesHeight: CGFloat = 93        // Shoes row height — locked to Figma spec
        static let rowSpacing: CGFloat = 8
        static let captionTopPadding: CGFloat = 16
        static let captionHorizontalPadding: CGFloat = 16
        static let canvasVerticalPadding: CGFloat = 8
    }

    // MARK: - Init

    init(
        tops: OutfitCategory = OutfitCategory(items: ["shirt_blue"]),
        bottoms: OutfitCategory = OutfitCategory(items: ["trousers_dark"]),
        shoes: OutfitCategory = OutfitCategory(items: ["shoes_loafer"]),
        captionText: String = "Linen for the heat, loafers for the lunch"
    ) {
        self.tops = tops
        self.bottoms = bottoms
        self.shoes = shoes
        self.captionText = captionText
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            outfitStack
            captionZone
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(ArenColor.Surface.primary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(captionText)
        .debugBorder(if: showDebugBorders, color: .red)
    }

    // MARK: - Outfit Stack

    private var outfitStack: some View {
        VStack(spacing: 0) {
            SwipableGarmentView(
                items: tops.items,
                currentIndex: $topsIndex,
                height: Layout.topsHeight,
                showDebugBorders: showDebugBorders
            )

            SwipableGarmentView(
                items: bottoms.items,
                currentIndex: $bottomsIndex,
                height: Layout.bottomsHeight,
                showDebugBorders: showDebugBorders
            )
            .padding(.top, Layout.rowSpacing)

            SwipableGarmentView(
                items: shoes.items,
                currentIndex: $shoesIndex,
                height: Layout.shoesHeight,
                showDebugBorders: showDebugBorders
            )
            .padding(.top, Layout.rowSpacing)
        }
        .frame(width: Layout.canvasWidth, alignment: .center)
        .padding(.vertical, Layout.canvasVerticalPadding)
        .debugBorder(if: showDebugBorders, color: .blue)
    }

    // MARK: - Caption

    private var captionZone: some View {
        Text(captionText)
            .font(captionFont)
            .foregroundStyle(ArenColor.Text.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .padding(.top, Layout.captionTopPadding)
            .padding(.horizontal, Layout.captionHorizontalPadding)
            .debugBorder(if: showDebugBorders, color: .yellow)
    }

    // MARK: - Caption Font
    // TODO: Replace with ArenTypography token once design system is finalised

    private var captionFont: Font {
        let candidates = ["HelveticaNowText-Light", "HelveticaNowText-Regular"]
        for name in candidates where UIFont(name: name, size: 11) != nil {
            return .custom(name, size: 11)
        }
        return .system(size: 11, weight: .light)
    }
}

// MARK: - SwipableGarmentView

private struct SwipableGarmentView: View {

    let items: [String]
    @Binding var currentIndex: Int
    let height: CGFloat
    let showDebugBorders: Bool

    private let width: CGFloat = 257    // Garment width — locked to Figma spec
    @State private var lastIndex: Int = 0

    var body: some View {
        guard !items.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            ZStack(alignment: .topLeading) {
                TabView(selection: $currentIndex) {
                    ForEach(items.indices, id: \.self) { index in
                        garmentImage(items[index])
                            .frame(width: width, height: height)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(width: width, height: height)
                .clipped()
                .onChange(of: currentIndex) { _, newValue in
                    guard newValue != lastIndex else { return }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    lastIndex = newValue
                }

                if items.count > 1 {
                    counterLabel
                }
            }
            .debugBorder(if: showDebugBorders, color: .green)
        )
    }

    private var counterLabel: some View {
        Text("\(currentIndex + 1) / \(items.count)")
            .font(.custom("Helvetica Now Text", size: 9).weight(.light))
            .foregroundStyle(ArenColor.Text.tertiary)
            .padding(.top, 8)
            .padding(.leading, 8)
            .animation(.easeInOut(duration: 0.2), value: currentIndex)
    }

    private func garmentImage(_ assetName: String) -> some View {
        let prefixed = assetName.hasPrefix("Outfit/") ? assetName : "Outfit/\(assetName)"
        return Image(prefixed)
            .interpolation(.high)
            .antialiased(true)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

// MARK: - Preview

#Preview {
    OutfitCardEditorialStackView(
        tops: OutfitCategory(items: ["shirt_blue", "shirt_white", "polo_navy"]),
        bottoms: OutfitCategory(items: ["trousers_dark", "chinos_stone"]),
        shoes: OutfitCategory(items: ["shoes_loafer", "shoes_derby"]),
        captionText: "Linen for the heat, loafers for the lunch"
    )
    .background(ArenColor.Surface.primary)
}
