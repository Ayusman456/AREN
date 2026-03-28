import SwiftUI

struct DemoBannerView: View {
    let text: String
    let onTapJoin: () -> Void

    var body: some View {
        HStack(spacing: ArenSpacing.md) {
            VStack(alignment: .leading, spacing: ArenSpacing.xs) {
                Text("Demo Wardrobe")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ArenColor.Text.primary)

                Text(text)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(ArenColor.Text.secondary)
            }

            Spacer()

            Button("Join") {
                onTapJoin()
            }
            .buttonStyle(.plain)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(ArenColor.Surface.primary)
            .padding(.horizontal, ArenSpacing.md)
            .padding(.vertical, ArenSpacing.sm)
            .background(
                Capsule()
                    .fill(ArenColor.Fill.primary)
            )
        }
        .padding(ArenSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(ArenColor.Surface.accentOrangePrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(ArenColor.Border.secondary, lineWidth: 1)
        )
    }
}
