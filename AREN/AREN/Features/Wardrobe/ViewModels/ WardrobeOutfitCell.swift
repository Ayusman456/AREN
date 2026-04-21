//
//  WardrobeOutfitCell.swift
//  AREN
//

import SwiftUI
import Kingfisher

struct WardrobeOutfitCell: View {

    let outfit: DailyOutfit
    let onTap: (() -> Void)?

    // MARK: - Layout

    private enum Layout {
        static let cardWidth: CGFloat       = 171
        static let imageHeight: CGFloat     = 257         // total canvas height
        static let topZoneHeight: CGFloat   = 80          // shirt/jacket — shorter garment
        static let bottomZoneHeight: CGFloat = 120        // trousers/skirt — tallest zone
        static let shoesZoneHeight: CGFloat  = 57         // shoes — compact, naturally small
        static let innerPadding: CGFloat    = 16          // breathing room inside each zone
        static let metaHorizontal: CGFloat  = 8
        static let metaBottom: CGFloat      = 12
        static let metaTopPadding: CGFloat  = 6
        static let metaLineSpacing: CGFloat = 4
        static let dateSize: CGFloat        = 10
        static let occasionSize: CGFloat    = 9
        static let dateTracking: CGFloat    = 0.5
        static let occasionTracking: CGFloat = 0.5
    }

    // MARK: - Debug

    #if DEBUG
    private let showDebugBorders = true
    #else
    private let showDebugBorders = false
    #endif

    // MARK: - Init

    init(outfit: DailyOutfit, onTap: (() -> Void)? = nil) {
        self.outfit = outfit
        self.onTap = onTap
    }

    // MARK: - Body

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {
                imageBlock
                metaBlock
            }
            .frame(width: Layout.cardWidth)
            .if(showDebugBorders) { $0.border(Color.red, width: 1) }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Image Block

    private var imageBlock: some View {
        VStack(spacing: 0) {
            garmentZone(item: outfit.top, height: Layout.topZoneHeight)
                .if(showDebugBorders) { $0.border(Color.blue, width: 1) }
            garmentZone(item: outfit.bottom, height: Layout.bottomZoneHeight)
                .if(showDebugBorders) { $0.border(Color.green, width: 1) }
            garmentZone(item: outfit.shoes, height: Layout.shoesZoneHeight)
                .if(showDebugBorders) { $0.border(Color.orange, width: 1) }
        }
        .frame(width: Layout.cardWidth, height: Layout.imageHeight)
        .background(Color(hex: "#F5F5F5"))
    }

    @ViewBuilder
    private func garmentZone(item: WardrobeItem?, height: CGFloat) -> some View {
        Group {
            if let item {
                switch item.garmentSource {
                case .remote(let url):
                    KFImage(url)
                        .placeholder { Color(hex: "#F5F5F5") }
                        .resizable()
                        .scaledToFit()
                        .padding(Layout.innerPadding)
                case .asset(let name):
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .padding(Layout.innerPadding)
                case .none:
                    Color(hex: "#EBEBEB")
                }
            } else {
                Color(hex: "#EBEBEB")
            }
        }
        .frame(width: Layout.cardWidth, height: height)
    }

    // MARK: - Meta Block

    private var metaBlock: some View {
        VStack(alignment: .leading, spacing: Layout.metaLineSpacing) {
            Text(formattedDate.uppercased())
                .font(.custom("HelveticaNowText-Light", size: Layout.dateSize).weight(.regular))
                .tracking(Layout.dateTracking)
                .lineLimit(1)
                .foregroundColor(ArenColor.Text.primary)

            Text((outfit.occasion ?? "—").uppercased())
                .font(.custom("HelveticaNowText-Light", size: Layout.occasionSize).weight(.regular))
                .tracking(Layout.occasionTracking)
                .lineLimit(1)
                .foregroundColor(Color(hex: "#999999"))
        }
        .padding(.horizontal, Layout.metaHorizontal)
        .padding(.top, Layout.metaTopPadding)
        .padding(.bottom, Layout.metaBottom)
    }

    // MARK: - Helpers

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: outfit.date)
    }
}

// MARK: - Conditional Modifier Helper

private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    ScrollView {
        LazyVGrid(
            columns: [GridItem(.fixed(171), spacing: 20), GridItem(.fixed(171), spacing: 20)],
            spacing: 32
        ) {
            WardrobeOutfitCell(outfit: .preview, onTap: { print("Outfit tapped") })
            WardrobeOutfitCell(outfit: .preview, onTap: { print("Outfit tapped") })
        }
        .padding(.horizontal, 20)
    }
}
#endif

