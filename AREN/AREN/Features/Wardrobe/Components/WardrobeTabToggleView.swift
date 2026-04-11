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
    
    private let showDebugBorders = true  // ← add this

    @Binding var selectedTab: WardrobeTab
    let itemCount: Int
    let outfitCount: Int

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            tabLabel(
                title: "ITEMS",
                count: itemCount,
                isActive: selectedTab == .items
            )
            .onTapGesture { selectedTab = .items }

            tabLabel(
                title: "OUTFITS",
                count: outfitCount,
                isActive: selectedTab == .outfits
            )
            .onTapGesture { selectedTab = .outfits }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 64)
        .debugBorder(if: showDebugBorders, color: .red)  // ← add this
    }

    // MARK: - Tab Label

    private func tabLabel(title: String, count: Int, isActive: Bool) -> some View {
        Text("\(title) | \(count) |")
            .font(labelFont(isActive: isActive))
            .kerning(0.8)
            .foregroundStyle(ArenColor.Text.primary)
            .animation(.easeInOut(duration: 0.15), value: isActive)
    }

    // MARK: - Font
    

    private func labelFont(isActive: Bool) -> Font {
        let candidates = isActive
            ? ["HelveticaNowText-Medium", "HelveticaNowText-Regular"]
            : ["HelveticaNowText-Light", "HelveticaNowText-Regular"]
        
        for name in candidates where UIFont(name: name, size: 13) != nil {
            return .custom(name, size: 13)
        }
        return .system(size: 13, weight: isActive ? .bold : .light)
    }
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
