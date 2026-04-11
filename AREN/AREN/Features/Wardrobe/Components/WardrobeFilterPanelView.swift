import SwiftUI
import UIKit

struct WardrobeFilterPanelView: View {

    // MARK: - Debug Toggle
    // true  → borders on for this component only
    // false → follows ArenDebug.isDebug
    private static let debug = true

    // MARK: - Layout

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

    // MARK: - Section Model

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

    // MARK: - Properties

    let sections: [Section]
    let selectedValues: [String: String]
    let onSelectOption: (String, String) -> Void
    let onViewResults: () -> Void

    // MARK: - Init

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

    // MARK: - Body

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
        .debugBorder(.blue, enabled: Self.debug)
    }

    // MARK: - Sections Viewport

    private var sectionsViewport: some View {
        VStack(alignment: .leading, spacing: Layout.rowGap) {
            ForEach(sections) { section in
                sectionRow(section)
            }
        }
        .frame(width: Layout.contentWidth, height: Layout.sectionsHeight, alignment: .topLeading)
        .debugBorder(.red, enabled: Self.debug)
    }

    // MARK: - Section Row

    private func sectionRow(_ section: Section) -> some View {
        HStack(alignment: .top, spacing: Layout.columnGap) {
            sectionLabel(section)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(section.options, id: \.self) { option in
                    optionRow(option, in: section)
                }
            }
            .frame(width: Layout.optionColumnWidth, alignment: .topLeading)
            .debugBorder(.orange, enabled: Self.debug)
        }
        .frame(width: Layout.contentWidth, alignment: .topLeading)
        .debugBorder(.pink, enabled: Self.debug)
    }

    // MARK: - Section Label

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
        .debugBorder(.purple, enabled: Self.debug)
    }

    // MARK: - Option Row

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

    // MARK: - Footer CTA

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
                    .stroke(ArenColor.Border.dark, lineWidth: 0.5)
            )
        }
        .padding(.horizontal, 0)
        .padding(.top, 20)
        .padding(.bottom, 0)
        .frame(width: Layout.contentWidth, height: Layout.footerHeight, alignment: .center)
        .debugBorder(.yellow, enabled: Self.debug)
    }

    // MARK: - Defaults

    private static let defaultSections: [Section] = [
        Section(number: "01", title: "Sort By", options: ["Recently added", "A–Z", "Brand"]),
        Section(number: "02", title: "Status",  options: ["All", "Worn", "Unworn"]),
        Section(number: "03", title: "Occasion", options: ["All", "Work", "Evening"]),
    ]

    // MARK: - Fonts

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

// MARK: - Preview

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
