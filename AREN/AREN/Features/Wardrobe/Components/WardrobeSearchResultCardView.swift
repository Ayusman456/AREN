import SwiftUI
import UIKit
import Kingfisher

struct WardrobeSearchResultCardView: View {
    private enum Layout {
        static let width: CGFloat = 171
        static let imageHeight: CGFloat = 256.5
        static let detailsTopPadding: CGFloat = 8
        static let titleOnlyHeight: CGFloat = 280.5
        static let compactHeight: CGFloat = 296.5
        static let statusHeight: CGFloat = 312.5
        static let addButtonSize: CGFloat = 14
        static let titleRowTrailingGap: CGFloat = 12
    }

    let imageAssetName: String
    let titleText: String
    let priceText: String?
    let statusText: String?
    let onAddTap: () -> Void
    let onTap: () -> Void

    init(
        imageAssetName: String,
        titleText: String,
        priceText: String? = nil,
        statusText: String? = nil,
        onAddTap: @escaping () -> Void = {},
        onTap: @escaping () -> Void = {}
    ) {
        self.imageAssetName = imageAssetName
        self.titleText = titleText
        self.priceText = priceText
        self.statusText = statusText
        self.onAddTap = onAddTap
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                imageCarousel
                detailsBlock
            }
            .frame(
                width: Layout.width,
                height: cardHeight,
                alignment: .top
            )
            .background(ArenColor.Surface.primary)
        }
        .buttonStyle(.plain)
    }

    private var imageCarousel: some View {
        Group {
            if imageAssetName.hasPrefix("http"),
               let url = URL(string: imageAssetName) {
                KFImage(url)
                    .placeholder {
                        Color(hex: "#F5F5F3")
                    }
                    .resizable()
                    .scaledToFit()
            } else {
                Image(imageAssetName)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            }
        }
        .frame(width: Layout.width, height: Layout.imageHeight)
        .clipped()
    }

    private var detailsBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let statusText {
                Text(statusText.uppercased())
                    .font(Self.statusFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .frame(maxWidth: .infinity, minHeight: 16, alignment: .leading)
            }

            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(titleText.uppercased())
                        .font(Self.titleFont)
                        .foregroundStyle(ArenColor.Text.primary)
                        .lineLimit(titleLineLimit)
                        .frame(maxWidth: .infinity, minHeight: 16, alignment: .leading)

                    if let priceText {
                        Text(priceText.uppercased())
                            .font(Self.priceFont)
                            .foregroundStyle(ArenColor.Text.primary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, minHeight: 16, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: onAddTap) {
                    Image("Plus")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Layout.addButtonSize, height: Layout.addButtonSize)
                        .foregroundStyle(ArenColor.Icon.primary)
                        .frame(width: Layout.addButtonSize, height: Layout.addButtonSize)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(width: 14, height: 14)
                .padding(.top, 1)
            }
            .padding(.trailing, Layout.titleRowTrailingGap)
            .frame(width: Layout.width, height: detailsHeight, alignment: .topLeading)
        }
        .padding(.top, Layout.detailsTopPadding)
        .frame(width: Layout.width, alignment: .topLeading)
    }

    private var cardHeight: CGFloat {
        if statusText != nil {
            return Layout.statusHeight
        }

        if priceText != nil {
            return Layout.compactHeight
        }

        return Layout.titleOnlyHeight
    }

    private var detailsHeight: CGFloat {
        priceText == nil ? 16 : 32
    }

    private var titleLineLimit: Int {
        statusText == nil ? 1 : 2
    }

    private static var titleFont: Font {
        customFont(size: 11)
    }

    private static var priceFont: Font {
        customFont(size: 11)
    }

    private static var statusFont: Font {
        customFont(size: 10)
    }

    private static func customFont(size: CGFloat) -> Font {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular",
        ]

        for name in candidates where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }

        return .system(size: size, weight: .light)
    }
}

#Preview {
    HStack(alignment: .top, spacing: 20) {
        WardrobeSearchResultCardView(
            imageAssetName: "Outfit/trousers_linen",
            titleText: "Slim fit cropped jeans"
        )
        WardrobeSearchResultCardView(
            imageAssetName: "Outfit/trousers_dark",
            titleText: "Slim fit jeans",
            priceText: "₹ 2,550.00",
            statusText: "Few items left"
        )
    }
    .padding(20)
    .background(Color.white)
}
