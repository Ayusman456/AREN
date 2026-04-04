import SwiftUI
import UIKit

struct WardrobeCategoryFilterStripView: View {
    let categories: [CategoryItem]
    let selectedCategory: String
    let onSelect: (String) -> Void

    init(
        categories: [CategoryItem] = Self.defaultCategories,
        selectedCategory: String = "Bottoms",
        onSelect: @escaping (String) -> Void = { _ in }
    ) {
        self.categories = categories
        self.selectedCategory = selectedCategory
        self.onSelect = onSelect
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
                .kerning(isSelected ? 0.0 : 0)
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
        .frame(height: 24, alignment: .center)
        .accessibilityLabel(category.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

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

    private static let defaultCategories: [CategoryItem] = [
        // These widths and edge insets come directly from the Figma item frames
        // so the first "ALL" label and the last trailing item stay locked to
        // the same grid measurements as the design.
        CategoryItem(title: "all", itemWidth: 49, contentWidth: 29, leadingInset: 20),
        CategoryItem(title: "Tops", itemWidth: 36),
        CategoryItem(title: "Bottoms", itemWidth: 70),
        CategoryItem(title: "Shoes", itemWidth: 47),
        CategoryItem(title: "Accessories", itemWidth: 95),
        CategoryItem(title: "Outerwear", itemWidth: 86),
        CategoryItem(title: "flare", itemWidth: 43),
        CategoryItem(title: "balloon", itemWidth: 64),
        CategoryItem(title: "wide leg", itemWidth: 65),
        CategoryItem(title: "skinny fit", itemWidth: 73),
        CategoryItem(title: "raw denim", itemWidth: 97, contentWidth: 77, trailingInset: 20),
    ]

    private static var inactiveFont: Font {
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

    private static var activeFont: Font {
        let candidates = [
            "HelveticaNowText-Medium",
            "HelveticaNowText Medium",
            "HelveticaNowText-Regular",
        ]

        for name in candidates where UIFont(name: name, size: 13) != nil {
            return .custom(name, size: 13)
        }

        return .system(size: 13, weight: .medium)
    }
}

#Preview {
    WardrobeCategoryFilterStripView()
        .background(ArenColor.Surface.primary)
}
