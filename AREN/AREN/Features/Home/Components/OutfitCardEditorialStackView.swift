import SwiftUI
import Kingfisher

// MARK: - GarmentSource

enum GarmentSource {
    case asset(String)
    case remote(URL)
}

// MARK: - Debug Border

extension View {
    @ViewBuilder
    func debugBorder(if show: Bool, color: Color = .red, width: CGFloat = 2) -> some View {
        if show { self.border(color, width: width) } else { self }
    }
}

// MARK: - View

struct OutfitCardEditorialStackView: View {

    #if DEBUG
    private let showDebugBorders = false
    #else
    private let showDebugBorders = false
    #endif

    let tops: [WardrobeItem]
    let bottoms: [WardrobeItem]
    let shoes: [WardrobeItem]

    @Binding var topIndex: Int
    @Binding var bottomIndex: Int
    @Binding var shoesIndex: Int

    let captionText: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            outfitStack
            captionZone
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(ArenColor.Surface.primary)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(captionText)
        .debugBorder(if: showDebugBorders, color: .red)
    }

    // MARK: - Outfit Stack

    private var outfitStack: some View {
        VStack(spacing: 0) {
            SwipableGarmentRow(
                items: tops,
                currentIndex: $topIndex,
                width: OutfitLayout.topsWidth,
                height: OutfitLayout.topsHeight,
                accessibilityLabel: "Top",
                showDebugBorders: showDebugBorders
            )

            SwipableGarmentRow(
                items: bottoms,
                currentIndex: $bottomIndex,
                width: OutfitLayout.bottomsWidth,
                height: OutfitLayout.bottomsHeight,
                accessibilityLabel: "Bottom",
                showDebugBorders: showDebugBorders
            )
            .padding(.top, OutfitLayout.rowSpacing)

            SwipableGarmentRow(
                items: shoes,
                currentIndex: $shoesIndex,
                width: OutfitLayout.shoesWidth,
                height: OutfitLayout.shoesHeight,
                accessibilityLabel: "Shoes",
                showDebugBorders: showDebugBorders
            )
            .padding(.top, OutfitLayout.rowSpacing)
        }
        .frame(width: OutfitLayout.canvasWidth, alignment: .center)
        .padding(.vertical, OutfitLayout.canvasVerticalPadding)
        .debugBorder(if: showDebugBorders, color: .blue)
    }

    // MARK: - Caption

    private var captionZone: some View {
        Text(captionText)
            .font(captionFont)
            .foregroundStyle(ArenColor.Text.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .debugBorder(if: showDebugBorders, color: .yellow)
    }

    private var captionFont: Font {
        let name = HomeViewModel.resolvedCaptionFontName
        return name.isEmpty ? .system(size: 11, weight: .light) : .custom(name, size: 11)
    }
}

// MARK: - SwipableGarmentRow

private struct SwipableGarmentRow: View {

    let items: [WardrobeItem]
    @Binding var currentIndex: Int
    let width: CGFloat
    let height: CGFloat
    let accessibilityLabel: String
    let showDebugBorders: Bool

    @State private var dragOffset: CGFloat  = 0
    @State private var flashOpacity: Double = 0

    // FIX 4: @State so generator persists across SwiftUI re-renders
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    private let dragThreshold: CGFloat = 40

    // MARK: - Body

    @ViewBuilder
    var body: some View {
        if items.isEmpty {
            Color(ArenColor.Surface.secondary)
                .frame(width: width, height: height)
        } else if !items.indices.contains(currentIndex) {
            Color(ArenColor.Surface.secondary)
                .frame(width: width, height: height)
        } else {
            ZStack(alignment: .topLeading) {
                garmentImage(items[currentIndex])
                    .frame(width: width, height: height)
                    .clipped()
                    .offset(x: dragOffset)

                // Peek — next
                if dragOffset < -8, currentIndex < items.count - 1 {
                    garmentImage(items[currentIndex + 1])
                        .frame(width: width, height: height)
                        .clipped()
                        .offset(x: width + dragOffset)
                        .mask(
                            LinearGradient(
                                // FIX 5: use surface color — not hardcoded .white
                                gradient: Gradient(colors: [.clear, Color(ArenColor.Surface.primary)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                // Peek — previous
                if dragOffset > 8, currentIndex > 0 {
                    garmentImage(items[currentIndex - 1])
                        .frame(width: width, height: height)
                        .clipped()
                        .offset(x: -width + dragOffset)
                        .mask(
                            LinearGradient(
                                // FIX 5: use surface color — not hardcoded .white
                                gradient: Gradient(colors: [Color(ArenColor.Surface.primary), .clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                // Snap flash overlay
                Color.white
                    .frame(width: width, height: height)
                    .opacity(flashOpacity)
                    .allowsHitTesting(false)

                if items.count > 1 {
                    counterLabel
                }
            }
            .frame(width: width, height: height)
            .clipped()
            .gesture(dragGesture)
            .accessibilityLabel("\(accessibilityLabel), \(currentIndex + 1) of \(items.count)")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: snap(to: currentIndex + 1)
                case .decrement: snap(to: currentIndex - 1)
                @unknown default: break
                }
            }
            .debugBorder(if: showDebugBorders, color: .green)
        }
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let t = value.translation.width
                if (currentIndex == 0 && t > 0) ||
                   (currentIndex == items.count - 1 && t < 0) {
                    dragOffset = t * 0.2   // rubber-band at boundaries
                } else {
                    dragOffset = t
                }
            }
            .onEnded { value in
                let t      = value.translation.width
                let atStart = currentIndex == 0 && t > 0
                let atEnd   = currentIndex == items.count - 1 && t < 0

                if atStart || atEnd {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        dragOffset = 0
                    }
                } else if t < -dragThreshold {
                    snap(to: currentIndex + 1)
                } else if t > dragThreshold {
                    snap(to: currentIndex - 1)
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = 0
                    }
                }
            }
    }

    // MARK: - Snap

    private func snap(to index: Int) {
        guard items.indices.contains(index) else { return }
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
        }
        currentIndex = index
        triggerFlash()
    }

    // MARK: - Flash

    private func triggerFlash() {
        flashOpacity = 0.5
        withAnimation(.easeOut(duration: 0.2)) {
            flashOpacity = 0
        }
    }

    // MARK: - Counter

    private var counterLabel: some View {
        Text("\(currentIndex + 1) / \(items.count)")
            .font(.custom("HelveticaNowText-Light", size: 9))
            .foregroundStyle(ArenColor.Text.tertiary)
            .padding(.top, 8)
            .padding(.leading, 8)
            .animation(.easeInOut(duration: 0.2), value: currentIndex)
    }

    // MARK: - Garment Image

    // FIX 6: Kingfisher for remote — caching, retry, progressive loading
    // FIX 7: Outfit/ namespace prefix resolved here, not in garmentSource
    @ViewBuilder
    private func garmentImage(_ item: WardrobeItem) -> some View {
        if let source = item.garmentSource {
            switch source {
            case .asset(let name):
                Image(resolvedAssetName(for: name))
                    .interpolation(.high)
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

            case .remote(let url):
                KFImage(url)
                    .placeholder {
                        Color(ArenColor.Surface.secondary)
                    }
                    .retry(maxCount: 2, interval: .seconds(1))
                    .interpolation(.high)
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else {
            Color(ArenColor.Surface.secondary)
        }
    }

    private func resolvedAssetName(for name: String) -> String {
        let prefixedName = "Outfit/\(name)"
        if UIImage(named: prefixedName) != nil {
            return prefixedName
        }
        if UIImage(named: name) != nil {
            return name
        }
        return prefixedName
    }
}

// MARK: - Preview

#Preview {
    OutfitCardEditorialStackView(
        tops:    [WardrobeItem(id: UUID(uuidString: "00000000-0000-0000-0001-000000000001")!, category: "Tops",    imageURL: nil, assetName: "shirt_001")],
        bottoms: [WardrobeItem(id: UUID(uuidString: "00000000-0000-0000-0002-000000000001")!, category: "Bottoms", imageURL: nil, assetName: "trouser_001")],
        shoes:   [WardrobeItem(id: UUID(uuidString: "00000000-0000-0000-0003-000000000001")!, category: "Shoes",   imageURL: nil, assetName: "shoes_001")],
        topIndex:    .constant(0),
        bottomIndex: .constant(0),
        shoesIndex:  .constant(0),
        captionText: "Your outfit for today"
    )
    .background(ArenColor.Surface.primary)
}
