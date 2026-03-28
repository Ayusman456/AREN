import SwiftUI

struct SwipeRow: View {
    let row: SwipeRowState
    let onSelectionChanged: (Int) -> Void

    @GestureState private var dragTranslation: CGFloat = 0

    private let cardWidth: CGFloat = 132
    private let cardSpacing: CGFloat = ArenSpacing.md

    var body: some View {
        VStack(alignment: .leading, spacing: ArenSpacing.sm) {
            VStack(alignment: .leading, spacing: ArenSpacing.xs) {
                Text(row.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(ArenColor.Text.primary)

                Text(row.subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(ArenColor.Text.secondary)
            }

            GeometryReader { proxy in
                let stride = cardWidth + cardSpacing
                let horizontalInset = max((proxy.size.width - cardWidth) / 2, 0)

                HStack(spacing: cardSpacing) {
                    ForEach(row.items) { item in
                        card(for: item)
                            .frame(width: cardWidth)
                    }
                }
                .padding(.horizontal, horizontalInset)
                .offset(x: dragTranslation - (CGFloat(row.activeIndex) * stride))
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .updating($dragTranslation) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            let predicted = value.predictedEndTranslation.width
                            let threshold = stride * 0.32
                            var nextIndex = row.activeIndex

                            if predicted < -threshold {
                                nextIndex += 1
                            } else if predicted > threshold {
                                nextIndex -= 1
                            }

                            nextIndex = min(max(nextIndex, 0), row.items.count - 1)
                            onSelectionChanged(nextIndex)
                        }
                )
                .animation(.spring(response: 0.28, dampingFraction: 0.84), value: row.activeIndex)
            }
            .frame(height: 176)
        }
    }

    private func card(for item: HomeOutfitCard) -> some View {
        VStack(alignment: .leading, spacing: ArenSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(ArenColor.Surface.secondary)

                Image(namespacedAssetName(for: item.assetName))
                    .resizable()
                    .scaledToFit()
                    .padding(ArenSpacing.md)
            }
            .frame(height: 120)

            Text(item.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ArenColor.Text.primary)
                .lineLimit(1)

            Text(item.note)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(ArenColor.Text.secondary)
                .lineLimit(1)
        }
        .padding(ArenSpacing.md)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(ArenColor.Surface.primary)
                .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(ArenColor.Border.secondary, lineWidth: 1)
        )
    }

    private func namespacedAssetName(for assetName: String) -> String {
        assetName.hasPrefix("Outfit/") ? assetName : "Outfit/\(assetName)"
    }
}
