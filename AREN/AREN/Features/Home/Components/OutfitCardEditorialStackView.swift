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
    var currentIndex: Int = 0
    var currentItem: String { items[currentIndex] }
}

// MARK: - View

struct OutfitCardEditorialStackView: View {
    
    // 👈 TOGGLE THIS ONCE TO SHOW/HIDE ALL DEBUG BORDERS
    private let showDebugBorders = false
    
    @State private var topsIndex: Int = 0
    @State private var bottomsIndex: Int = 0
    @State private var shoesIndex: Int = 0
    
    let tops: OutfitCategory
    let bottoms: OutfitCategory
    let shoes: OutfitCategory
    let captionText: String

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

    var body: some View {
        VStack(spacing: 0) {
            outfitStack
            captionZone
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(ArenColor.Surface.primary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(captionText)
        .debugBorder(if: showDebugBorders, color: .red, width: 2)
    }

    // MARK: - Outfit Stack

    private var outfitStack: some View {
        VStack(spacing: 0) {
            SwipableGarmentView(
                items: tops.items,
                currentIndex: $topsIndex,
                height: 216,
                showDebugBorders: showDebugBorders
            )
            
            SwipableGarmentView(
                items: bottoms.items,
                currentIndex: $bottomsIndex,
                height: 246,
                showDebugBorders: showDebugBorders
            )
            .padding(.top, 8)
            
            SwipableGarmentView(
                items: shoes.items,
                currentIndex: $shoesIndex,
                height: 93,
                showDebugBorders: showDebugBorders
            )
            .padding(.top, 8)
        }
        .frame(width: 280, alignment: .center)
        .padding(.vertical, 8)
        .debugBorder(if: showDebugBorders, color: .blue, width: 2)
    }

    // MARK: - Caption Zone

    private var captionZone: some View {
        Text(captionText)
            .font(Self.captionFont)
            .foregroundStyle(ArenColor.Text.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .padding(.top, 12)
            .padding(.horizontal, 16)
            .debugBorder(if: showDebugBorders, color: .yellow, width: 2)
    }

    // MARK: - Swipable Garment Component
    
    struct Constants {
      static let textTextTertiary: Color = Color(red: 0.53, green: 0.53, blue: 0.53)
    }

    private struct SwipableGarmentView: View {
        let items: [String]
        @Binding var currentIndex: Int
        let height: CGFloat
        let showDebugBorders: Bool

        @State private var dragOffset: CGFloat = 0
        @State private var isAnimating = false

        // 🔧 Tweak these to adjust swipe feel
        private let containerWidth: CGFloat = 257
        private let peekWidth: CGFloat = 50          // How much of next item shows
        private let snapThreshold: CGFloat = 80      // Distance needed to trigger snap
        private let rubberBandLimit: CGFloat = 40    // Max stretch at edges
        private let velocityThreshold: CGFloat = 500 // Fast flick threshold

        var body: some View {
            ZStack(alignment: .topLeading) {
                // Current Item
                garmentImage(items[currentIndex])
                    .frame(width: containerWidth, height: height)
                    .offset(x: dragOffset)

                // Next Item (Peeking)
                if currentIndex < items.count - 1 {
                    garmentImage(items[currentIndex + 1])
                        .frame(width: containerWidth, height: height)
                        .offset(x: containerWidth - peekWidth + dragOffset)
                        .opacity(dragOffset < -20 ? 1 : 0) // Simple fade in
                }

                // Counter (Simple fade animation)
                Text("\(currentIndex + 1) / \(items.count)")
                    .font(Font.custom("Helvetica Now Text", size: 9).weight(.light))
                    .foregroundStyle(Constants.textTextTertiary)
                    .padding(.top, 8)
                    .padding(.leading, 8)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
            .frame(width: containerWidth, height: height)
            .gesture(dragGesture)
            .debugBorder(if: showDebugBorders, color: .green, width: 2)
        }

        private var dragGesture: some Gesture {
            DragGesture()
                .onChanged { value in
                    if isAnimating { return }
                    dragOffset = calculateBoundedOffset(value.translation.width)
                }
                .onEnded { value in
                    if isAnimating { return }
                    isAnimating = true
                    
                    let velocity = value.predictedEndTranslation.width
                    var shouldSnap = false
                    
                    if dragOffset < -snapThreshold || velocity < -velocityThreshold {
                        if currentIndex < items.count - 1 {
                            currentIndex += 1
                            shouldSnap = true
                        }
                    } else if dragOffset > snapThreshold || velocity > velocityThreshold {
                        if currentIndex > 0 {
                            currentIndex -= 1
                            shouldSnap = true
                        }
                    }
                    
                    if shouldSnap {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        dragOffset = 0
                        isAnimating = false
                    }
                }
        }

        private func calculateBoundedOffset(_ translation: CGFloat) -> CGFloat {
            if translation > 0 {
                // Swiping right (previous item)
                if currentIndex == 0 {
                    return min(translation, rubberBandLimit) // Rubber band at start
                }
                return min(translation, containerWidth * 0.3)
            } else {
                // Swiping left (next item)
                if currentIndex == items.count - 1 {
                    return max(translation, -rubberBandLimit) // Rubber band at end
                }
                return max(translation, -containerWidth * 0.3)
            }
        }

        private func garmentImage(_ assetName: String) -> some View {
            Image(assetName.hasPrefix("Outfit/") ? assetName : "Outfit/\(assetName)")
                .interpolation(.high)
                .antialiased(true)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    // MARK: - Helpers

    private static let captionFont: Font = {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular",
        ]
        for name in candidates where UIFont(name: name, size: 11) != nil {
            return .custom(name, size: 11)
        }
        return .system(size: 11, weight: .light)
    }()
}

// MARK: - Preview

#Preview {
    OutfitCardEditorialStackView(
        tops: OutfitCategory(items: ["shirt_blue", "shirt_white", "polo_navy"]),
        bottoms: OutfitCategory(items: ["trousers_dark", "chinos_stone"], currentIndex: 0),
        shoes: OutfitCategory(items: ["shoes_loafer", "shoes_derby"]),
        captionText: "Linen for the heat, loafers for the lunch"
    )
    .background(ArenColor.Surface.primary)
}
