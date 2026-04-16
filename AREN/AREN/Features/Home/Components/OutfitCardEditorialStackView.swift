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

// MARK: - GarmentSource

enum GarmentSource {
    case asset(String)
    case remote(URL)
}

// MARK: - View

struct OutfitCardEditorialStackView: View {

    private let showDebugBorders = false

    let tops: [WardrobeItem]
    let bottoms: [WardrobeItem]
    let shoes: [WardrobeItem]

    @Binding var topIndex: Int
    @Binding var bottomIndex: Int
    @Binding var shoesIndex: Int

    let captionText: String

    // MARK: - Layout Constants

    private enum Layout {
        static let canvasWidth: CGFloat = 280
        static let topsWidth: CGFloat = 257
        static let bottomsWidth: CGFloat = 233
        static let shoesWidth: CGFloat = 95
        static let topsHeight: CGFloat = 216
        static let bottomsHeight: CGFloat = 246
        static let shoesHeight: CGFloat = 93
        static let rowSpacing: CGFloat = 8
        static let captionTopPadding: CGFloat = 16
        static let captionHorizontalPadding: CGFloat = 16
        static let canvasVerticalPadding: CGFloat = 8
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
            SwipableGarmentRow(
                items: tops,
                currentIndex: $topIndex,
                width: Layout.topsWidth,
                height: Layout.topsHeight,
                showDebugBorders: showDebugBorders
            )

            SwipableGarmentRow(
                items: bottoms,
                currentIndex: $bottomIndex,
                width: Layout.bottomsWidth,
                height: Layout.bottomsHeight,
                showDebugBorders: showDebugBorders
            )
            .padding(.top, Layout.rowSpacing)

            SwipableGarmentRow(
                items: shoes,
                currentIndex: $shoesIndex,
                width: Layout.shoesWidth,
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

    private var captionFont: Font {
        let candidates = ["HelveticaNowText-Light", "HelveticaNowText-Regular"]
        for name in candidates where UIFont(name: name, size: 11) != nil {
            return .custom(name, size: 11)
        }
        return .system(size: 11, weight: .light)
    }
}

// MARK: - SwipableGarmentRow

private struct SwipableGarmentRow: View {

    let items: [WardrobeItem]
    @Binding var currentIndex: Int
    let width: CGFloat
    let height: CGFloat
    let showDebugBorders: Bool

    @State private var dragOffset: CGFloat = 0
    @State private var showFlash: Bool = false

    private let dragThreshold: CGFloat = 40

    var body: some View {
        guard !items.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            ZStack(alignment: .topLeading) {
                // Current item
                garmentImage(items[currentIndex])
                    .frame(width: width, height: height)
                    .clipped()
                    .offset(x: dragOffset)

                // Adjacent peek — next item
                if dragOffset < 0, currentIndex < items.count - 1 {
                    garmentImage(items[currentIndex + 1])
                        .frame(width: width, height: height)
                        .clipped()
                        .offset(x: width + dragOffset)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .white]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                // Adjacent peek — previous item
                if dragOffset > 0, currentIndex > 0 {
                    garmentImage(items[currentIndex - 1])
                        .frame(width: width, height: height)
                        .clipped()
                        .offset(x: -width + dragOffset)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors: [.white, .clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                // Snap flash overlay
                if showFlash {
                    Color.white
                        .frame(width: width, height: height)
                        .allowsHitTesting(false)
                }

                // Counter
                if items.count > 1 {
                    counterLabel
                }
            }
            .frame(width: width, height: height)
            .clipped()
            .gesture(dragGesture)
            .debugBorder(if: showDebugBorders, color: .green)
        )
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.width
                // Rubber band at boundaries
                if (currentIndex == 0 && translation > 0) ||
                   (currentIndex == items.count - 1 && translation < 0) {
                    dragOffset = translation * 0.2
                } else {
                    dragOffset = translation
                }
            }
            .onEnded { value in
                let translation = value.translation.width
                let atStart = currentIndex == 0 && translation > 0
                let atEnd = currentIndex == items.count - 1 && translation < 0

                if atStart || atEnd {
                    // Boundary — shake feedback, spring back
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        dragOffset = 0
                    }
                } else if translation < -dragThreshold {
                    snap(to: currentIndex + 1)
                } else if translation > dragThreshold {
                    snap(to: currentIndex - 1)
                } else {
                    // Below threshold — spring back
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = 0
                    }
                }
            }
    }

    // MARK: - Snap

    private func snap(to index: Int) {
        guard items.indices.contains(index) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
        }
        currentIndex = index
        triggerFlash()
    }

    private func triggerFlash() {
        showFlash = true
        withAnimation(.easeOut(duration: 0.15)) {
            showFlash = false
        }
    }

    // MARK: - Counter

    private var counterLabel: some View {
        Text("\(currentIndex + 1) / \(items.count)")
            .font(.custom("Helvetica Now Text", size: 9).weight(.light))
            .foregroundStyle(ArenColor.Text.tertiary)
            .padding(.top, 8)
            .padding(.leading, 8)
            .animation(.easeInOut(duration: 0.2), value: currentIndex)
    }

    // MARK: - Garment Image

    private func garmentImage(_ item: WardrobeItem) -> some View {
        Group {
            if let source = item.garmentSource {
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
                        case .failure, .empty:
                            Color(hex: "#F5F5F3")
                        @unknown default:
                            Color(hex: "#F5F5F3")
                        }
                    }
                }
            } else {
                Color(hex: "#F5F5F3")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OutfitCardEditorialStackView(
        tops: [WardrobeItem(id: UUID(), category: "Tops", imageURL: nil, assetName: "shirt_001")],
        bottoms: [WardrobeItem(id: UUID(), category: "Bottoms", imageURL: nil, assetName: "trouser_001")],
        shoes: [WardrobeItem(id: UUID(), category: "Shoes", imageURL: nil, assetName: "shoes_001")],
        topIndex: .constant(0),
        bottomIndex: .constant(0),
        shoesIndex: .constant(0),
        captionText: "Your outfit for today"
    )
    .background(ArenColor.Surface.primary)
}
