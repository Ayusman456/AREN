import SwiftUI
import UIKit

enum HomeTabBarItem: String, CaseIterable, Hashable, Identifiable {
    case home = "HOME"
    case wardrobe = "WARDROBE"
    case events = "EVENTS"
    case profile = "PROFILE"

    var id: String { rawValue }
}

struct HomeTabBarView: View {
    let activeItem: HomeTabBarItem
    let onSelect: (HomeTabBarItem) -> Void

    init(
        activeItem: HomeTabBarItem = .home,
        onSelect: @escaping (HomeTabBarItem) -> Void = { _ in }
    ) {
        self.activeItem = activeItem
        self.onSelect = onSelect
    }

    var body: some View {
        ZStack(alignment: .top) {
            HStack(alignment: .center) {
                ForEach(Array(HomeTabBarItem.allCases.enumerated()), id: \.element) { index, item in
                    tabButton(for: item)

                    if index < HomeTabBarItem.allCases.count - 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(width: 402, height: 48, alignment: .center)
            .background(ArenColor.Surface.primary)

            Rectangle()
                .fill(ArenColor.Fill.primary.opacity(0.1))
                .frame(width: 402, height: 0.5)
        }
        .frame(width: 402, height: 48)
        .background(ArenColor.Surface.primary)
    }

    private func tabButton(for item: HomeTabBarItem) -> some View {
        Button(action: { onSelect(item) }) {
            VStack(spacing: 4) {
                Text(item.rawValue)
                    .font(Self.tabFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .opacity(item == activeItem ? 1.0 : 0.7)
                    .lineLimit(1)

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(ArenColor.Fill.primary)
                    .frame(width: 4, height: 4)
                    .opacity(item == activeItem ? 1.0 : 0.0)
            }
            .frame(height: 24, alignment: .center)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.rawValue.capitalized)
    }

    private static var tabFont: Font {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular",
        ]

        for name in candidates where UIFont(name: name, size: 12) != nil {
            return .custom(name, size: 12)
        }

        return .system(size: 12, weight: .light)
    }
}

#Preview("Home") {
    HomeTabBarView(activeItem: .home)
        .frame(width: 402)
        .background(ArenColor.Surface.primary)
}

#Preview("Wardrobe") {
    HomeTabBarView(activeItem: .wardrobe)
        .frame(width: 402)
        .background(ArenColor.Surface.primary)
}

#Preview("Events") {
    HomeTabBarView(activeItem: .events)
        .frame(width: 402)
        .background(ArenColor.Surface.primary)
}

#Preview("Profile") {
    HomeTabBarView(activeItem: .profile)
        .frame(width: 402)
        .background(ArenColor.Surface.primary)
}
