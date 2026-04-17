import SwiftUI

//  AREN
//
//  Created by Ayusman sahu on 12/04/26.
//

// MARK: - WardrobeTabToggleView

enum WardrobeTab {
    case items
    case outfits
}

struct WardrobeTabToggleView: View {
    private let showDebugBorders = false

    @Binding var selectedTab: WardrobeTab
    let itemCount: Int
    let outfitCount: Int

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            tabView(
                title: "ITEMS",
                count: itemCount,
                isActive: selectedTab == .items
            )
            .contentShape(Rectangle())
            .onTapGesture { selectedTab = .items }

            tabView(
                title: "OUTFITS",
                count: outfitCount,
                isActive: selectedTab == .outfits
            )
            .contentShape(Rectangle())
            .onTapGesture { selectedTab = .outfits }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, Layout.contentInset)
        .padding(.vertical, Layout.contentInset)
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(ArenColor.Surface.primary)
        .debugBorder(if: showDebugBorders, color: .red)
    }

    // MARK: - Tab

    private func tabView(title: String, count: Int, isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: Layout.titleToCountSpacing) {
                tabText(title, isActive: isActive)
                countRow(count: count, isActive: isActive)
            }
        }
        .padding(.vertical, Layout.tabVerticalPadding)
        .fixedSize(horizontal: true, vertical: true)
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }

    private func tabText(_ title: String, isActive: Bool) -> some View {
        Text(title)
            .font(labelFont(isActive: isActive))
            .kerning(isActive ? Layout.activeTracking : 0)
            .foregroundStyle(ArenColor.Text.primary)
            .lineLimit(1)
    }

    private func countRow(count: Int, isActive: Bool) -> some View {
        HStack(alignment: .center, spacing: isActive ? Layout.activeCountSpacing : Layout.inactiveCountSpacing) {
            divider(width: isActive ? Layout.activeDividerWidth : Layout.inactiveDividerWidth)

            Text("\(count)")
                .font(labelFont(isActive: isActive))
                .kerning(isActive ? Layout.activeTracking : 0)
                .foregroundStyle(ArenColor.Text.primary)
                .lineLimit(1)

            divider(width: isActive ? Layout.activeDividerWidth : Layout.inactiveDividerWidth)
        }
    }

    private func divider(width: CGFloat) -> some View {
        Rectangle()
            .fill(ArenColor.Text.primary)
            .frame(width: width, height: Layout.dividerHeight)
    }

    // MARK: - Font


    private func labelFont(isActive: Bool) -> Font {
        let candidates = isActive
            ? ["HelveticaNowText-Medium", "HelveticaNowText Medium", "HelveticaNowText-Regular"]
            : ["HelveticaNowText-Light", "HelveticaNowText Light", "HelveticaNowText-Regular"]

        for name in candidates where UIFont(name: name, size: 13) != nil {
            return .custom(name, size: 13)
        }
        return .system(size: 13, weight: isActive ? .medium : .light)
    }
}

private enum Layout {
    static let contentInset: CGFloat = 20
    static let tabVerticalPadding: CGFloat = 4
    static let titleToCountSpacing: CGFloat = 4
    static let activeCountSpacing: CGFloat = 5.9
    static let inactiveCountSpacing: CGFloat = 7.3
    static let activeDividerWidth: CGFloat = 1.5
    static let inactiveDividerWidth: CGFloat = 0.5
    static let dividerHeight: CGFloat = 12
    static let activeTracking: CGFloat = 0.8
}

// MARK: - Preview

#Preview {
    @Previewable @State var tab: WardrobeTab = .items
    WardrobeTabToggleView(
        selectedTab: $tab,
        itemCount: 37,
        outfitCount: 23
    )
}
