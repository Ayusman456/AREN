import SwiftUI
import UIKit

struct WardrobeTopNavView: View {
    enum Mode: Hashable {
        case filtersSearchAdd
        case cancel
    }

    let mode: Mode
    let showsBackButton: Bool
    // ✅ FIX 3 — Changed from Bool to Double to support mid-opacity states (0.85)
    let backgroundOpacity: Double

    let onBackTap: () -> Void
    let onFiltersTap: () -> Void
    let onSearchTap: () -> Void
    let onAddTap: () -> Void

    init(
        mode: Mode = .filtersSearchAdd,
        showsBackButton: Bool = true,
        backgroundOpacity: Double = 1.0,
        onBackTap: @escaping () -> Void = {},
        onFiltersTap: @escaping () -> Void = {},
        onSearchTap: @escaping () -> Void = {},
        onAddTap: @escaping () -> Void = {}
    ) {
        self.mode = mode
        self.showsBackButton = showsBackButton
        self.backgroundOpacity = backgroundOpacity
        self.onBackTap = onBackTap
        self.onFiltersTap = onFiltersTap
        self.onSearchTap = onSearchTap
        self.onAddTap = onAddTap
    }

    var body: some View {
        Group {
            switch mode {
            case .filtersSearchAdd:
                filtersSearchAddLayout
            case .cancel:
                cancelLayout
            }
        }
    }

    private var filtersSearchAddLayout: some View {
        HStack(spacing: 0) {
            backContainer
            Spacer()
            trailingActions
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(navBackground)
    }

    private var cancelLayout: some View {
        HStack {
            cancelContainer
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(navBackground)
    }

    // ✅ FIX 3 — Single view with opacity driven by Double, animates correctly at all values
    private var navBackground: some View {
        ArenColor.Surface.primary
            .opacity(backgroundOpacity)
            .animation(.easeInOut(duration: 0.2), value: backgroundOpacity)
    }

    private var backContainer: some View {
        HStack(spacing: 0) {
            if showsBackButton {
                Button(action: onBackTap) {
                    Image("ArrowLeft")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(ArenColor.Icon.primary)
                        .frame(width: 40, height: 40)
                }
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .padding(.leading, 8)
        .frame(width: 60, alignment: .leading)
    }

    private var cancelContainer: some View {
        Button(action: onBackTap) {
            Text("CANCEL")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(ArenColor.Text.primary)
                .frame(height: 48)
        }
        .padding(.leading, 12)
    }

    private var trailingActions: some View {
        HStack(spacing: 4) {
            Button(action: onFiltersTap) {
                Text("FILTERS")
                    .font(Self.labelFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .frame(height: 16)
                    .padding(.leading, 8)
                    .padding(.trailing, 12)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.plain)

            iconButton("MagnifyingGlass", action: onSearchTap)
            iconButton("Plus", action: onAddTap)
        }
        .padding(.trailing, 12)
        .frame(width: 168, alignment: .trailing)
    }

    private func iconButton(_ name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(name)
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(ArenColor.Icon.primary)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
    }

    private static var labelFont: Font {
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
