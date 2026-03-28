import SwiftUI
import UIKit

struct OutfitCardEditorialStackView: View {
    let shirtAssetName: String
    let trouserAssetName: String
    let shoeAssetName: String
    let captionText: String

    init(
        shirtAssetName: String = "shirt_blue",
        trouserAssetName: String = "trousers_dark",
        shoeAssetName: String = "shoes_loafer",
        captionText: String = "Linen for the heat, loafers for the lunch"
    ) {
        self.shirtAssetName = shirtAssetName
        self.trouserAssetName = trouserAssetName
        self.shoeAssetName = shoeAssetName
        self.captionText = captionText
    }

    var body: some View {
        VStack(spacing: 0) {
            outfitStack
                .padding(.vertical, 8)

            captionZone
        }
        .frame(width: 402)
        .background(ArenColor.Surface.primary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(captionText)
    }

    private var outfitStack: some View {
        VStack(spacing: 0) {
            garmentImage(shirtAssetName)
                .frame(width: 257, height: 216)

            ZStack {
                garmentImage(trouserAssetName)
                    .frame(width: 233, height: 246)
            }
            .frame(width: 257, height: 246)

            ZStack {
                garmentImage(shoeAssetName)
                    .frame(width: 95, height: 95)
            }
            .frame(width: 257, height: 93)
        }
        .frame(width: 280, height: 570)
    }

    private var captionZone: some View {
        Text(captionText)
            .font(Self.captionFont)
            .foregroundStyle(ArenColor.Text.primary)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .frame(width: 402, height: 20, alignment: .center)
    }

    @ViewBuilder
    private func garmentImage(_ assetName: String) -> some View {
        Image(namespacedAssetName(for: assetName))
            .interpolation(.high)
            .antialiased(true)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    private func namespacedAssetName(for assetName: String) -> String {
        assetName.hasPrefix("Outfit/") ? assetName : "Outfit/\(assetName)"
    }

    private static var captionFont: Font {
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

#Preview {
    OutfitCardEditorialStackView()
        .background(ArenColor.Surface.primary)
}
