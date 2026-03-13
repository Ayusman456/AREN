import SwiftUI

struct ArenVStack<Content: View>: View {
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: Content

    init(
        _ spacing: CGFloat = ArenSpacing.md,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.alignment = alignment
        self.content = content()
    }

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content
        }
    }
}

struct ArenHStack<Content: View>: View {
    let spacing: CGFloat
    let alignment: VerticalAlignment
    let content: Content

    init(
        _ spacing: CGFloat = ArenSpacing.md,
        alignment: VerticalAlignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.alignment = alignment
        self.content = content()
    }

    var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            content
        }
    }
}

struct ArenSpacer: View {
    let size: CGFloat

    init(_ size: CGFloat = ArenSpacing.md) {
        self.size = size
    }

    var body: some View {
        Spacer()
            .frame(height: size)
    }
}

extension View {
    func arenPadding(
        _ edges: Edge.Set = .all,
        _ amount: CGFloat = ArenSpacing.md
    ) -> some View {
        padding(edges, amount)
    }
}
