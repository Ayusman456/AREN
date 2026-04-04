import SwiftUI
import UIKit

struct WardrobeTopNavView: View {
    enum Mode: Hashable {
        case filtersSearchAdd
        case cancel
    }

    let mode: Mode
    let showsBackButton: Bool
    let onBackTap: () -> Void
    let onFiltersTap: () -> Void
    let onSearchTap: () -> Void
    let onAddTap: () -> Void

    init(
        mode: Mode = .filtersSearchAdd,
        showsBackButton: Bool = true,
        onBackTap: @escaping () -> Void = {},
        onFiltersTap: @escaping () -> Void = {},
        onSearchTap: @escaping () -> Void = {},
        onAddTap: @escaping () -> Void = {}
    ) {
        self.mode = mode
        self.showsBackButton = showsBackButton
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
        HStack(alignment: .top, spacing: 0) {
            backContainer

            Spacer(minLength: 0)

            trailingActions
        }
        .frame(width: 402, height: 48, alignment: .topLeading)
        .background(ArenColor.Surface.primary)
    }

    private var cancelLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            cancelContainer

            Spacer(minLength: 0)

            Color.clear
                .frame(width: 168, height: 48)
        }
        .frame(width: 402, height: 48, alignment: .topLeading)
        .background(ArenColor.Surface.primary)
    }

    private var backContainer: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showsBackButton {
                Button(action: onBackTap) {
                    ZStack {
                        Color.clear
                            .frame(width: 20, height: 20)

                        Image("ArrowLeft")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(ArenColor.Icon.primary)
                    }
                    .frame(width: 40, height: 40, alignment: .center)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(width: 40, height: 48, alignment: .center)
            } else {
                Color.clear
                    .frame(width: 40, height: 48)
            }
        }
        // Primary tab screens like Wardrobe intentionally hide the back button,
        // but we preserve the left slot so the top-nav grid stays aligned.
        .padding(.leading, 8)
        .frame(width: 60, height: 48, alignment: .topLeading)
    }

    private var cancelContainer: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onBackTap) {
                Text("CANCEL")
                    .font(Self.filtersFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .lineLimit(1)
                    .lineSpacing(0)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(height: 16, alignment: .leading)
                    .padding(.leading, 8)
                    .padding(.trailing, 12)
                    .frame(height: 48, alignment: .center)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 11)
        .frame(width: 60, height: 48, alignment: .topLeading)
    }

    private var trailingActions: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                filtersButton
                iconButton(assetName: "MagnifyingGlass", action: onSearchTap)
                iconButton(assetName: "Plus", action: onAddTap)
            }
            .frame(width: 156, height: 48, alignment: .trailing)
        }
        .padding(.trailing, 12)
        .frame(width: 168, height: 48, alignment: .topTrailing)
    }

    private var filtersButton: some View {
        Button(action: onFiltersTap) {
            Text("FILTERS")
                .font(Self.filtersFont)
                .foregroundStyle(ArenColor.Text.primary)
                .lineLimit(1)
                .lineSpacing(0)
                .frame(width: 48, height: 16, alignment: .center)
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .frame(height: 48, alignment: .center)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func iconButton(assetName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(assetName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(ArenColor.Icon.primary)
                .frame(width: 40, height: 40, alignment: .center)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(width: 40, height: 48, alignment: .center)
    }

    private static var filtersFont: Font {
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

#Preview {
    WardrobeTopNavView()
        .background(ArenColor.Surface.primary)
}
