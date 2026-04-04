import SwiftUI

struct LayoutGridOverlayView: View {
    private let canvasWidth: CGFloat = 402
    private let horizontalInset: CGFloat = 20
    private let gutter: CGFloat = 12
    private let columnCount: Int = 4

    var body: some View {
        GeometryReader { proxy in
            let columnWidth = (canvasWidth - (horizontalInset * 2) - (gutter * CGFloat(columnCount - 1))) / CGFloat(columnCount)

            HStack(spacing: gutter) {
                ForEach(0..<columnCount, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(0.035))
                        .frame(width: columnWidth)
                        .overlay {
                            Rectangle()
                                .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                        }
                }
            }
            .frame(width: canvasWidth, height: proxy.size.height)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        Color.white
        LayoutGridOverlayView()
    }
}
