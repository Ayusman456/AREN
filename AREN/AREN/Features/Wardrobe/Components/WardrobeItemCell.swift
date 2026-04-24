import SwiftUI
import Kingfisher
import UIKit

struct WardrobeItemCell: View {
    let item: WardrobeItem

    private enum Layout {
        static let cardWidth: CGFloat = 171
        static let imageHeight: CGFloat = 257
        static let imagePadding: CGFloat = 24
        static let metadataHorizontalPadding: CGFloat = 8
        static let metadataTopPadding: CGFloat = 6
        static let metadataBottomPadding: CGFloat = 12
        static let metadataLineSpacing: CGFloat = 4
        static let textLineHeight: CGFloat = 16
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageBlock
            metaBlock
        }
        .frame(width: Layout.cardWidth, alignment: .topLeading)
        .background(ArenColor.Surface.primary)
    }

    // MARK: - Image

    @ViewBuilder
    private var imageBlock: some View {
        if let source = item.garmentSource {
            garmentImage(for: source)
        } else if item.isProcessing {
            processingPlaceholder
        } else {
            emptyImagePlaceholder
        }
    }

    @ViewBuilder
    private func garmentImage(for source: GarmentSource) -> some View {
        switch source {
        case .remote(let url):
            KFImage(url)
                .placeholder { loadingPlaceholder }
                .resizable()
                .scaledToFit()
                .padding(Layout.imagePadding)
                .frame(width: Layout.cardWidth, height: Layout.imageHeight)
        case .asset(let assetName):
            Image(assetName)
                .resizable()
                .scaledToFit()
                .padding(Layout.imagePadding)
                .frame(width: Layout.cardWidth, height: Layout.imageHeight)
        }
    }

    // MARK: - Placeholders

    private var processingPlaceholder: some View {
        ZStack {
            ArenColor.Surface.secondary
            VStack(spacing: 8) {
                ProgressView()
                    .tint(ArenColor.Text.tertiary)
                Text("PROCESSING")
                    .font(Self.metadataFont)
                    .tracking(1.5)
                    .foregroundStyle(ArenColor.Text.tertiary)
            }
        }
        .frame(width: Layout.cardWidth, height: Layout.imageHeight)
    }

    private var loadingPlaceholder: some View {
        ArenColor.Surface.secondary
            .frame(width: Layout.cardWidth, height: Layout.imageHeight)
    }

    private var emptyImagePlaceholder: some View {
        ArenColor.Surface.tertiary
            .frame(width: Layout.cardWidth, height: Layout.imageHeight)
    }

    // MARK: - Meta

    private var metaBlock: some View {
        VStack(alignment: .leading, spacing: Layout.metadataLineSpacing) {
            Text(item.name.uppercased())
                .font(Self.metadataFont)
                .lineLimit(1)
                .foregroundStyle(ArenColor.Text.primary)
                .frame(height: Layout.textLineHeight, alignment: .leading)

            Text((item.category ?? "").uppercased())
                .font(Self.metadataFont)
                .lineLimit(1)
                .foregroundStyle(ArenColor.Text.primary)
                .frame(height: Layout.textLineHeight, alignment: .leading)
        }
        .padding(.horizontal, Layout.metadataHorizontalPadding)
        .padding(.top, Layout.metadataTopPadding)
        .padding(.bottom, Layout.metadataBottomPadding)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private static var metadataFont: Font {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular",
        ]

        for name in candidates where UIFont(name: name, size: 11) != nil {
            return .custom(name, size: 11)
        }

        return .system(size: 11, weight: .light)
    }
}
