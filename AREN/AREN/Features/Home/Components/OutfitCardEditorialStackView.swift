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
enum GarmentSource {
    case asset(String)
    case remote(URL)
}

struct OutfitCategory {
    let items: [GarmentSource]
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
        static let shoesHeight: CGFloat = 93
        static let rowSpacing: CGFloat = 8
        static let captionTopPadding: CGFloat = 16
        static let captionHorizontalPadding: CGFloat = 16
        static let canvasVerticalPadding: CGFloat = 8
        static let topsWidth: CGFloat = 257
        static let bottomsWidth: CGFloat = 233
        static let shoesWidth: CGFloat = 95
    }

    // MARK: - Init

    init(
        tops: OutfitCategory = OutfitCategory(items: [.asset("shirt_blue")]),
        bottoms: OutfitCategory = OutfitCategory(items: [.asset("trousers_dark")]),
        shoes: OutfitCategory = OutfitCategory(items: [.asset("shoes_loafer")]),
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
                width: 257,
                height: Layout.topsHeight,
                showDebugBorders: showDebugBorders
            )

            SwipableGarmentView(
                items: bottoms.items,
                currentIndex: $bottomsIndex,
                width: 233,
                height: Layout.bottomsHeight,
                showDebugBorders: showDebugBorders
            )

            SwipableGarmentView(
                items: shoes.items,
                currentIndex: $shoesIndex,
                width: 95,
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

    let items: [GarmentSource]
    @Binding var currentIndex: Int
    let width: CGFloat
    let height: CGFloat
    let showDebugBorders: Bool

    @State private var lastIndex: Int = 0

    var body: some View {
        guard !items.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            ZStack(alignment: .topLeading) {
                TabView(selection: $currentIndex) {
                    ForEach(items.indices, id: \.self) { index in
                        garmentImage(items[index])
                            .frame(width: width, height: height)
                            .clipped()
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

    private func garmentImage(_ source: GarmentSource) -> some View {
        Group {
            switch source {
            case .asset(let name):
                let prefixed = name.hasPrefix("Outfit/") ? name : "Outfit/\(name)"
                Image(prefixed)
                    .interpolation(.high)
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .remote(let url):
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .interpolation(.high)
                            .antialiased(true)
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Color(hex: "#F5F5F3")
                    case .empty:
                        Color(hex: "#F5F5F3")
                    @unknown default:
                        Color(hex: "#F5F5F3")
                    }
                }
            }
        }
    }
}

// MARK: - Preview
// ✅ FIXED: Preview moved to file scope (outside any struct)
#Preview {
    OutfitCardEditorialStackView(
        tops: OutfitCategory(items: [.asset("shirt_blue"), .asset("shirt_white")]),
        bottoms: OutfitCategory(items: [.asset("trousers_dark")]),
        shoes: OutfitCategory(items: [.asset("shoes_loafer")]),
        captionText: "Linen for the heat, loafers for the lunch"
    )
    .background(ArenColor.Surface.primary)
}
