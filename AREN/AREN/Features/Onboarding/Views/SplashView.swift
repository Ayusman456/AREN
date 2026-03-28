import SwiftUI

struct SplashView: View {
    @State private var isVisible = false

    var body: some View {
        ZStack {
            ArenColor.Surface.primary
                .ignoresSafeArea()

            Text("ARĒN")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(ArenColor.Text.primary)
                .opacity(isVisible ? 1 : 0.2)
                .scaleEffect(isVisible ? 1 : 0.96)
                .animation(.easeOut(duration: 0.45), value: isVisible)
        }
        .task {
            isVisible = true
        }
    }
}

#Preview {
    SplashView()
}
