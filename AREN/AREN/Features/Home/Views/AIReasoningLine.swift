import SwiftUI

struct AIReasoningLine: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: ArenSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ArenColor.Icon.accentOrange)
                .padding(.top, 2)

            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(ArenColor.Text.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
