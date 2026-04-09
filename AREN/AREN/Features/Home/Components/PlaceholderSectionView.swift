import SwiftUI

struct PlaceholderSectionView: View {
    let title: String

    var body: some View {
        ZStack {
            ArenColor.Surface.primary
                .ignoresSafeArea()

            Text(title)
                .font(.custom("HelveticaNowText-Light", size: 24))
                .foregroundStyle(ArenColor.Text.secondary)
        }
    }
}

#Preview {
    PlaceholderSectionView(title: "Events")
}
