import SwiftUI
import UIKit

struct WardrobeCategoryFilterStripView: View {
    let categories: [CategoryItem]
    let selectedCategory: String
    let onSelect: (String) -> Void

    init(
        selectedCategory: String = "All",
        tab: WardrobeTab = .items,
        onSelect: @escaping (String) -> Void = { _ in }
    ) {
        self.selectedCategory = selectedCategory
        self.onSelect = onSelect
        self.categories = tab == .items
            ? Self.itemCategories
            : Self.outfitCategories
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 20) {
                    ForEach(categories) { category in
                        categoryButton(for: category)
                    }
                }
                .frame(height: 24, alignment: .topLeading)
            }
            .scrollClipDisabled()
            .frame(width: 402, height: 24, alignment: .leading)
            .clipped()

            Spacer(minLength: 0)
        }
        .frame(width: 402, height: 40, alignment: .topLeading)
        .background(ArenColor.Surface.primary)
    }

    private func categoryButton(for category: CategoryItem) -> some View {
        let isSelected = category.title.caseInsensitiveCompare(selectedCategory) == .orderedSame

        return Button(action: { onSelect(category.title) }) {
            Text(category.title.uppercased())
                .font(isSelected ? Self.activeFont : Self.inactiveFont)
                .foregroundStyle(ArenColor.Text.primary)
                .lineLimit(1)
                .frame(width: category.contentWidth, height: 16, alignment: .leading)
                .padding(.leading, category.leadingInset)
                .padding(.trailing, category.trailingInset)
                .padding(.vertical, 4)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(width: category.itemWidth, height: 24, alignment: .leading)
        .accessibilityLabel(category.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // MARK: - Category Item

    struct CategoryItem: Identifiable, Hashable {
        let id: String
        let title: String
        let itemWidth: CGFloat
        let contentWidth: CGFloat
        let leadingInset: CGFloat
        let trailingInset: CGFloat

        init(
            title: String,
            itemWidth: CGFloat,
            contentWidth: CGFloat? = nil,
            leadingInset: CGFloat = 0,
            trailingInset: CGFloat = 0
        ) {
            self.id = title.lowercased()
            self.title = title
            self.itemWidth = itemWidth
            self.contentWidth = contentWidth ?? (itemWidth - leadingInset - trailingInset)
            self.leadingInset = leadingInset
            self.trailingInset = trailingInset
        }
    }

    // MARK: - Category Sets

    private static let itemCategories: [CategoryItem] = [
        CategoryItem(title: "All", itemWidth: 49, contentWidth: 29, leadingInset: 20),
        CategoryItem(title: "Tops", itemWidth: 36),
        CategoryItem(title: "Bottoms", itemWidth: 70),
        CategoryItem(title: "Shoes", itemWidth: 47),
        CategoryItem(title: "Accessories", itemWidth: 95),
        CategoryItem(title: "Outerwear", itemWidth: 86, contentWidth: 66, trailingInset: 20),
    ]

    private static let outfitCategories: [CategoryItem] = [
        CategoryItem(title: "All", itemWidth: 49, contentWidth: 29, leadingInset: 20),
        CategoryItem(title: "Casual", itemWidth: 57),
        CategoryItem(title: "Work", itemWidth: 45),
        CategoryItem(title: "Date", itemWidth: 40),
        CategoryItem(title: "Events", itemWidth: 80, contentWidth: 60, trailingInset: 20),
    ]

    // MARK: - Fonts

    private static var inactiveFont: Font {
        let candidates = ["HelveticaNowText-Light", "HelveticaNowText-Regular"]
        for name in candidates where UIFont(name: name, size: 13) != nil {
            return .custom(name, size: 13)
        }
        return .system(size: 13, weight: .light)
    }

    private static var activeFont: Font {
        let candidates = ["HelveticaNowText-Medium", "HelveticaNowText-Regular"]
        for name in candidates where UIFont(name: name, size: 13) != nil {
            return .custom(name, size: 13)
        }
        return .system(size: 13, weight: .medium)
    }
}

#Preview("Items") {
    WardrobeCategoryFilterStripView(selectedCategory: "Tops", tab: .items)
        .background(ArenColor.Surface.primary)
}

#Preview("Outfits") {
    WardrobeCategoryFilterStripView(selectedCategory: "Work", tab: .outfits)
        .background(ArenColor.Surface.primary)
}
