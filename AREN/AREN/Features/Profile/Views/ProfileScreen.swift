import SwiftUI

struct ProfileScreen: View {
    let sessionTitle: String
    let sessionMessage: String
    let onAuthRequested: (AuthContext) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ArenSpacing.lg) {
                    Text("Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(ArenColor.Text.primary)

                    VStack(alignment: .leading, spacing: ArenSpacing.sm) {
                        Text(sessionTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ArenColor.Text.primary)

                        Text(sessionMessage)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(ArenColor.Text.secondary)
                    }
                    .padding(ArenSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(ArenColor.Surface.secondary)
                    )

                    Button {
                        onAuthRequested(.nudge)
                    } label: {
                        Text("Link Apple or Google")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(ArenColor.Surface.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, ArenSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(ArenColor.Fill.primary)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(ArenSpacing.lg)
            }
            .background(ArenColor.Surface.primary.ignoresSafeArea())
        }
    }
}

#Preview {
    ProfileScreen(sessionTitle: "Anonymous session active", sessionMessage: "Preview session message") { _ in }
}
