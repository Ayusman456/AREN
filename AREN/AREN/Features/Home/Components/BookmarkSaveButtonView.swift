import SwiftUI

struct BookmarkSaveButtonView: View {
    let isSaved: Bool
    let onTap: () -> Void

    private let outlineAssetName = "Save-Outfit-outline"
    private let fillAssetName = "Save-Outfit-fill"

    var body: some View {
        Button(action: onTap) {
            // Keep the asset swap local to this component so future bookmark
            // animations don't leak into the home-screen layout code.
            Image(isSaved ? fillAssetName : outlineAssetName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Outline") {
    BookmarkSaveButtonView(isSaved: false, onTap: {})
        .padding()
        .background(.white)
}

#Preview("Filled") {
    BookmarkSaveButtonView(isSaved: true, onTap: {})
        .padding()
        .background(.white)
}
