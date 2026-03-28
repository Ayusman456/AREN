import SwiftUI

struct HomeScreen: View {
    let onAuthRequested: (AuthContext) -> Void

    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: ArenSpacing.xl) {
                    header
                    ContextBarView(title: viewModel.contextTitle, subtitle: viewModel.contextSubtitle)
                    DemoBannerView(text: viewModel.demoBannerText) {
                        onAuthRequested(.join)
                    }
                    OutfitZoneView(rows: viewModel.rows) { row, index in
                        viewModel.selectItem(in: row, index: index)
                    }
                    AIReasoningLine(text: viewModel.reasoningLine)
                }
                .padding(.horizontal, ArenSpacing.lg)
                .padding(.top, ArenSpacing.lg)
                .padding(.bottom, ArenSpacing.section)
            }
            .background(ArenColor.Surface.primary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: ArenSpacing.sm) {
            Text("ARĒN")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(ArenColor.Text.primary)

            HStack(spacing: ArenSpacing.sm) {
                Text("V2 outfit shell")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(ArenColor.Text.primary)

                Text("Swaps tracked: \(viewModel.wearHistoryCount)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(ArenColor.Text.secondary)
            }
        }
    }
}

#Preview {
    HomeScreen { _ in }
}
