import SwiftUI
import Kingfisher

struct WardrobeItemCell: View {
    let item: WardrobeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            imageBlock
            metaBlock
        }
        .frame(width: 171)
       // .border(Color.red, width: 1) // DEBUG
    }

    // MARK: - Image

    @ViewBuilder
    private var imageBlock: some View {
        if item.isProcessing {
            processingPlaceholder
        } else if let urlString = item.imageURL, let url = URL(string: urlString) {
            KFImage(url)
                .placeholder { loadingPlaceholder }
                .resizable()
                .scaledToFit()
                .padding(24)
                .frame(width: 171, height: 228)
                .background(Color(hex: "#F5F5F5"))
         //       .border(Color.blue, width: 1) // DEBUG
        } else {
            emptyImagePlaceholder
        }
    }

    // MARK: - Placeholders

    private var processingPlaceholder: some View {
        ZStack {
            Color(hex: "#F5F5F3")
            VStack(spacing: 8) {
                ProgressView()
                    .tint(Color(hex: "#999999"))
                Text("PROCESSING")
                    .font(.system(size: 9, weight: .regular))
                    .tracking(1.5)
                    .foregroundColor(Color(hex: "#999999"))
            }
        }
        .frame(width: 171, height: 228)
    }

    private var loadingPlaceholder: some View {
        Color(hex: "#F5F5F3")
            .frame(width: 171, height: 228)
    }

    private var emptyImagePlaceholder: some View {
        Color(hex: "#EBEBEB")
            .frame(width: 171, height: 228)
    }

    // MARK: - Meta

    private var metaBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.name.uppercased())
                .font(.system(size: 10, weight: .regular))
                .tracking(0.5)
                .lineLimit(1)
                .foregroundColor(.black)

            Text((item.category ?? "").uppercased())
                .font(.system(size: 9, weight: .regular))
                .tracking(0.5)
                .foregroundColor(Color(hex: "#999999"))
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 12)
    }
}
