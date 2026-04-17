import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject var homeViewModel: HomeViewModel

    // MARK: - Demo Data

    private let demoEvents: [DayDetailModalView.ScheduleEvent] = [
        .init(title: "Client Lunch",   timeText: "1:00 PM", occasion: "Business Casual"),
        .init(title: "Team Standup",   timeText: "3:00 PM", occasion: "Business"),
        .init(title: "Dinner with Sara", timeText: "7:30 PM", occasion: "Evening")
    ]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ScheduleRowView(
                state: .withDate,
                dateText: "SAT 21",
                titleText: "CLIENT LUNCH",
                timeText: "1:00 PM",
                overflowCount: 2,
                onOverflowTap: {
                    router.present(sheet: .dayDetail(date: .now, events: demoEvents))
                }
            )

            if homeViewModel.isLoading {
                loadingSkeleton
            } else {
                outfitCanvas
                confirmOutfitCTA
            }

            Spacer(minLength: 0)
        }
        .background(ArenColor.Surface.primary)
        .task {
            homeViewModel.loadOutfitIfNeeded()
        }
    }

    // MARK: - Outfit Canvas

    private var outfitCanvas: some View {
        ZStack(alignment: .topTrailing) {
            OutfitCardEditorialStackView(
                tops:    homeViewModel.tops,
                bottoms: homeViewModel.bottoms,
                shoes:   homeViewModel.shoes,
                topIndex:    $homeViewModel.topIndex,
                bottomIndex: $homeViewModel.bottomIndex,
                shoesIndex:  $homeViewModel.shoesIndex,
                captionText: homeViewModel.displayCaption.isEmpty
                    ? "Your outfit for today"
                    : homeViewModel.displayCaption
            )

            BookmarkSaveButtonView(isSaved: homeViewModel.isOutfitSaved) {
                homeViewModel.isOutfitSaved.toggle()
            }
            .padding(.top, 16)
            .padding(.trailing, 20)
        }
        .padding(.bottom, 8)
    }

    private var confirmOutfitCTA: some View {
        ConfirmOutfitCTAView(
            state: homeViewModel.confirmCTAState,
            action: {
                Task {
                    await homeViewModel.confirmOutfit()
                }
            }
        )
        .modifier(ShakeModifier(trigger: homeViewModel.confirmCTAState == .error))
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
    
    //shake modifier
    
    struct ShakeModifier: ViewModifier {
        let trigger: Bool
        @State private var offset: CGFloat = 0

        func body(content: Content) -> some View {
            content
                .offset(x: offset)
                .onChange(of: trigger) { _, isError in
                    guard isError else { return }
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
                        offset = 10
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
                            offset = -8
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                            offset = 0
                        }
                    }
                }
        }
    }

    // MARK: - Loading Skeleton

    private var loadingSkeleton: some View {
        VStack(spacing: 8) {
            skeletonRow(height: OutfitLayout.topsHeight)
            skeletonRow(height: OutfitLayout.bottomsHeight)
            skeletonRow(height: OutfitLayout.shoesHeight)
        }
        .padding(.vertical, OutfitLayout.canvasVerticalPadding)
        .frame(maxWidth: .infinity)
    }

    private func skeletonRow(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(ArenColor.Surface.secondary)
            .frame(maxWidth: OutfitLayout.canvasWidth)
            .frame(height: height)
            .opacity(0.5)
            .shimmering()
    }
}

// MARK: - Shimmer Modifier

extension View {
    func shimmering() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear,                    location: phase - 0.3),
                        .init(color: Color.white.opacity(0.4),  location: phase),
                        .init(color: .clear,                    location: phase + 0.3)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .blendMode(.plusLighter)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1.3
                }
            }
    }
}

// MARK: - Confirmation CTA Component

private struct ConfirmOutfitCTAView: View {
    let state: ConfirmOutfitCTAState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                switch state {
                case .default:
                    ctaLabel("WEARING THIS TODAY")
                case .loading:
                    ConfirmOutfitSpinner()
                case .error:
                    ctaLabel("TRY AGAIN")
                case .confirmed:
                    ctaLabel("WORN TODAY")
                }
            }
            .frame(width: 362, height: 32)
            .background(ArenColor.Surface.primary)
            .overlay {
                Rectangle()
                    .strokeBorder(ArenColor.Border.dark, lineWidth: 0.5)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(state == .loading || state == .confirmed)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private func ctaLabel(_ title: String) -> some View {
        Text(title)
            .font(Self.labelFont)
            .textCase(.uppercase)
            .foregroundStyle(ArenColor.Text.primary)
            .lineLimit(1)
            .frame(height: 16)
            .padding(.vertical, 1.5)
    }

    private var accessibilityLabel: String {
        switch state {
        case .default:   return "Wearing this today"
        case .loading:   return "Confirming outfit"
        case .error:     return "Try again"
        case .confirmed: return "Outfit confirmed"
        }
    }

    private static var labelFont: Font {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular",
        ]
        for name in candidates where UIFont(name: name, size: 13) != nil {
            return .custom(name, size: 13)
        }
        return .system(size: 13, weight: .light)
    }
}

// MARK: - Spinner Component

private struct ConfirmOutfitSpinner: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Capsule(style: .circular)
                    .fill(ArenColor.Fill.primary.opacity(opacity(for: index)))
                    .frame(width: 1, height: 2.5)
                    .offset(y: -7.5)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
        .frame(width: 20, height: 20)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }

    private func opacity(for index: Int) -> Double {
        let values: [Double] = [1.0, 0.92, 0.82, 0.72, 0.58, 0.46, 0.34, 0.24]
        return values[index]
    }
}

// MARK: - Preview

#Preview {
    HomeView(homeViewModel: HomeViewModel())
        .environmentObject(AppRouter())
}
