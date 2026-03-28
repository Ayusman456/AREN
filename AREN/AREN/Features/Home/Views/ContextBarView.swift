import SwiftUI

struct ContextBarView: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: ArenSpacing.sm) {
            Label(title, systemImage: "cloud.sun")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ArenColor.Text.primary)

            Spacer(minLength: ArenSpacing.sm)

            Text(subtitle)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(ArenColor.Text.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, ArenSpacing.lg)
        .padding(.vertical, ArenSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(ArenColor.Surface.secondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(ArenColor.Border.secondary, lineWidth: 1)
        )
    }
}
