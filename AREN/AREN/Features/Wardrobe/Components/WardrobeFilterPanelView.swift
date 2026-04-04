import SwiftUI
import UIKit

struct WardrobeFilterPanelView: View {
    private enum Layout {
        static let panelWidth: CGFloat = 402
        static let contentWidth: CGFloat = 362
        static let horizontalInset: CGFloat = 20
        static let verticalInset: CGFloat = 20
        static let rowGap: CGFloat = 20
        static let columnGap: CGFloat = 16
        static let labelWidth: CGFloat = 138.96
        static let optionColumnWidth: CGFloat = 207.04
        static let sectionsHeight: CGFloat = 328
        static let footerHeight: CGFloat = 72
        static let panelHeight: CGFloat = 440
    }

    struct Section: Identifiable, Hashable {
        let id: String
        let number: String
        let title: String
        let options: [String]

        init(number: String, title: String, options: [String]) {
            self.id = "\(number)-\(title.lowercased())"
            self.number = number
            self.title = title
            self.options = options
        }
    }

    let sections: [Section]
    let selectedValues: [String: String]
    let onSelectOption: (String, String) -> Void
    let onViewResults: () -> Void

    init(
        sections: [Section] = Self.defaultSections,
        selectedValues: [String: String] = [:],
        onSelectOption: @escaping (String, String) -> Void = { _, _ in },
        onViewResults: @escaping () -> Void = {}
    ) {
        self.sections = sections
        self.selectedValues = selectedValues
        self.onSelectOption = onSelectOption
        self.onViewResults = onViewResults
    }

    var body: some View {
        VStack(spacing: 0) {
            sectionsViewport

            footerCTA
        }
        .frame(width: Layout.contentWidth, height: Layout.sectionsHeight + Layout.footerHeight, alignment: .top)
        .padding(.horizontal, Layout.horizontalInset)
        .padding(.vertical, Layout.verticalInset)
        .frame(width: Layout.panelWidth, height: Layout.panelHeight, alignment: .center)
        .background(ArenColor.Surface.primary)
        // .border(.blue, width: 1)
    }

    private var sectionsViewport: some View {
        VStack(alignment: .leading, spacing: Layout.rowGap) {
            ForEach(sections) { section in
                sectionRow(section)
            }
        }
        .frame(width: Layout.contentWidth, height: Layout.sectionsHeight, alignment: .topLeading)
        // .border(.red, width: 1)
        // .border(.green, width: 1)
    }

    private func sectionRow(_ section: Section) -> some View {
        HStack(alignment: .top, spacing: Layout.columnGap) {
            sectionLabel(section)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(section.options, id: \.self) { option in
                    optionRow(option, in: section)
                }
            }
            .frame(width: Layout.optionColumnWidth, alignment: .topLeading)
            // .border(.orange, width: 1)
        }
        .frame(width: Layout.contentWidth, alignment: .topLeading)
        // .border(.pink, width: 1)
    }

    private func sectionLabel(_ section: Section) -> some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(ArenColor.Icon.primary)
                    .frame(width: 0.5, height: 12)

                Text(section.number)
                    .font(Self.sectionLabelFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .frame(minWidth: 19, alignment: .center)

                Rectangle()
                    .fill(ArenColor.Icon.primary)
                    .frame(width: 0.5, height: 12)
            }
            .frame(minWidth: 20, alignment: .leading)

            Text(section.title.uppercased())
                .font(Self.sectionLabelFont)
                .foregroundStyle(ArenColor.Text.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.trailing, 20)
        .frame(width: Layout.labelWidth, alignment: .topLeading)
        // .border(.purple, width: 1)
    }

    private func optionRow(_ option: String, in section: Section) -> some View {
        let isSelected = selectedValues[section.id]?.caseInsensitiveCompare(option) == .orderedSame

        return Button(action: { onSelectOption(section.id, option) }) {
            Text(option.uppercased())
                .font(Self.optionFont)
                .foregroundStyle(ArenColor.Text.primary)
                .frame(maxWidth: .infinity, minHeight: 16, alignment: .leading)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(width: Layout.optionColumnWidth, height: 32, alignment: .leading)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var footerCTA: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onViewResults) {
                Text("VIEW RESULTS")
                    .font(Self.optionFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .frame(maxWidth: .infinity, minHeight: 16)
                    .padding(.vertical, 7.5)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(width: Layout.contentWidth, height: 32)
            .overlay(
                Rectangle()
                    .stroke(ArenColor.Icon.primary, lineWidth: 1)
            )
        }
        .padding(.vertical, 20)
        .frame(width: Layout.contentWidth, height: Layout.footerHeight, alignment: .center)
        // .border(.black, width: 1)
    }

    private static let defaultSections: [Section] = [
        Section(number: "01", title: "Sort By", options: ["Recently added", "A–Z", "Brand"]),
        Section(number: "02", title: "Status", options: ["All", "Worn", "Unworn"]),
        Section(number: "03", title: "Occasion", options: ["All", "Work", "Evening"]),
    ]

    private static var sectionLabelFont: Font {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular",
        ]

        for name in candidates where UIFont(name: name, size: 11) != nil {
            return .custom(name, size: 11)
        }

        return .system(size: 11, weight: .light)
    }

    private static var optionFont: Font {
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

#Preview {
    WardrobeFilterPanelView(
        selectedValues: [
            "01-sort by": "Recently added",
            "02-status": "All",
            "03-occasion": "All",
        ]
    )
    .background(Color.gray.opacity(0.1))
}
