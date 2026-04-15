import SwiftUI

struct AuthSheetView: View {
    let context: AuthContext

    @Environment(\.dismiss) private var dismiss
    @State private var selectedProvider: AuthProvider?

    var body: some View {
        VStack(alignment: .leading, spacing: ArenSpacing.lg) {
            Capsule()
                .fill(ArenColor.Border.primary)
                .frame(width: 44, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, ArenSpacing.xs)

            Text(context.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(ArenColor.Text.primary)

            Text(context.message)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(ArenColor.Text.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: ArenSpacing.md) {
                providerButton(.apple, title: "Continue with Apple", icon: "apple.logo")
                providerButton(.google, title: "Continue with Google", icon: "globe")
            }

            Text(selectedProvider?.helperText ?? "Anonymous auth is already active. Provider migration is the next step in this flow.")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(ArenColor.Text.secondary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, ArenSpacing.lg)
        .padding(.bottom, ArenSpacing.xl)
        .background(ArenColor.Surface.primary)
    }

    private func providerButton(_ provider: AuthProvider, title: String, icon: String) -> some View {
        Button {
            selectedProvider = provider
            dismiss()
        } label: {
            HStack(spacing: ArenSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))

                Text(title)
                    .font(.system(size: 15, weight: .semibold))

                Spacer()
            }
            .foregroundStyle(ArenColor.Text.primary)
            .padding(.horizontal, ArenSpacing.lg)
            .padding(.vertical, ArenSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(ArenColor.Surface.secondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(ArenColor.Border.secondary, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private enum AuthProvider {
    case apple
    case google

    var helperText: String {
        switch self {
        case .apple:
            return "Apple upgrade flow will attach your current anonymous wardrobe to an Apple identity." //test
        case .google:
            return "Google upgrade flow will attach your current anonymous wardrobe to a Google identity."
        }
    }
}
