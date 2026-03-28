import SwiftUI

struct LayoutGridOverlayView: View {
    let columns: Int
    let horizontalInset: CGFloat
    let gutter: CGFloat
    let columnOpacity: Double
    let lineOpacity: Double

    init(
        columns: Int = 4,
        horizontalInset: CGFloat = 20,
        gutter: CGFloat = 12,
        columnOpacity: Double = 0.04,
        lineOpacity: Double = 0.08
    ) {
        self.columns = columns
        self.horizontalInset = horizontalInset
        self.gutter = gutter
        self.columnOpacity = columnOpacity
        self.lineOpacity = lineOpacity
    }

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = max(proxy.size.width - (horizontalInset * 2), 0)
            let totalGutterWidth = gutter * CGFloat(max(columns - 1, 0))
            let columnWidth = max((availableWidth - totalGutterWidth) / CGFloat(max(columns, 1)), 0)

            ZStack(alignment: .topLeading) {
                HStack(spacing: gutter) {
                    ForEach(0..<columns, id: \.self) { _ in
                        Rectangle()
                            .fill(ArenColor.Fill.primary.opacity(columnOpacity))
                            .frame(width: columnWidth)
                    }
                }
                .padding(.horizontal, horizontalInset)

                Rectangle()
                    .fill(ArenColor.Fill.primary.opacity(lineOpacity))
                    .frame(width: 1)
                    .offset(x: horizontalInset)

                Rectangle()
                    .fill(ArenColor.Fill.primary.opacity(lineOpacity))
                    .frame(width: 1)
                    .offset(x: proxy.size.width - horizontalInset)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    LayoutGridOverlayView()
        .frame(width: 402, height: 874)
        .background(ArenColor.Surface.primary)
}
