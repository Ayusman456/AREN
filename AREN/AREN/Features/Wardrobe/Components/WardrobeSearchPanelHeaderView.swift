import SwiftUI
import UIKit

struct WardrobeSearchPanelHeaderView: View {
    private enum Layout {
        static let width: CGFloat = 402
        static let height: CGFloat = 173
        static let topPadding: CGFloat = 44
        static let fieldWidth: CGFloat = 362
        static let fieldHeight: CGFloat = 33
        static let shellGap: CGFloat = 80
        static let fieldLeadingInset: CGFloat = 47
        static let fieldTrailingInset: CGFloat = 20
        static let placeholderTopInset: CGFloat = 7
        static let inputTopInset: CGFloat = 4
        static let recentHeaderWidth: CGFloat = 382
        static let trailingIconSlotWidth: CGFloat = 28
        static let trailingIconSize: CGFloat = 24
    }

    let placeholderText: String
    let recentHeaderText: String
    @Binding var query: String
    var isSearchFieldFocused: FocusState<Bool>.Binding

    init(
        placeholderText: String = "What are you looking for?",
        recentHeaderText: String = "RECENTLY ADDED",
        query: Binding<String>,
        isSearchFieldFocused: FocusState<Bool>.Binding
    ) {
        self.placeholderText = placeholderText
        self.recentHeaderText = recentHeaderText
        self._query = query
        self.isSearchFieldFocused = isSearchFieldFocused
    }

    var body: some View {
        VStack(alignment: .center, spacing: Layout.shellGap) {
            searchField
            recentHeader
        }
        .padding(.top, Layout.topPadding)
        .frame(width: Layout.width, height: Layout.height, alignment: .top)
        .background(ArenColor.Surface.primary)
    }

    private var searchField: some View {
        ZStack(alignment: .topLeading) {
            if !isSearchFieldFocused.wrappedValue {
                Rectangle()
                    .fill(Color(red: 204 / 255, green: 204 / 255, blue: 204 / 255))
                    .frame(height: 0.5)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }

            if query.isEmpty {
                Text(placeholderText.uppercased())
                    .font(Self.placeholderFont)
                    .foregroundStyle(Color(red: 117 / 255, green: 117 / 255, blue: 117 / 255))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, Layout.placeholderTopInset)
                    .padding(.leading, Layout.fieldLeadingInset)
                    .padding(.trailing, 48)
                    .opacity(isSearchFieldFocused.wrappedValue ? 1 : 1)
                    .allowsHitTesting(false)
            }

            HStack(spacing: 0) {
                TextField("", text: uppercaseQueryBinding)
                    .focused(isSearchFieldFocused)
                    .font(Self.placeholderFont)
                    .foregroundStyle(ArenColor.Text.primary)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
                    .submitLabel(.search)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 16, alignment: .center)
                    .opacity(query.isEmpty ? 0.01 : 1)

                Button(action: {
                    query = ""
                    isSearchFieldFocused.wrappedValue = true
                }) {
                    Image("Cancel")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Layout.trailingIconSize, height: Layout.trailingIconSize)
                        .foregroundStyle(ArenColor.Icon.primary)
                        .frame(width: Layout.trailingIconSlotWidth, height: Layout.trailingIconSize, alignment: .leading)
                }
                .buttonStyle(.plain)
                .opacity(query.isEmpty ? 0 : 1)
                .allowsHitTesting(!query.isEmpty)
            }
            .padding(.top, Layout.inputTopInset)
            .padding(.leading, Layout.fieldLeadingInset)
            .padding(.trailing, Layout.fieldTrailingInset)
        }
        .frame(width: Layout.fieldWidth, height: Layout.fieldHeight, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture {
            isSearchFieldFocused.wrappedValue = true
        }
    }

    private var recentHeader: some View {
        HStack(spacing: 0) {
            Text(recentHeaderText.uppercased())
                .font(Self.recentHeaderFont)
                .foregroundStyle(ArenColor.Text.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: Layout.recentHeaderWidth, height: 16, alignment: .leading)
        .padding(.leading, 20)
        .frame(width: Layout.width, alignment: .leading)
    }

    private static var placeholderFont: Font {
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

    private static var recentHeaderFont: Font {
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

    private var uppercaseQueryBinding: Binding<String> {
        Binding(
            get: { query.uppercased() },
            set: { query = $0.uppercased() }
        )
    }
}

#Preview {
    PreviewHost()
        .background(Color.gray.opacity(0.08))
}

private struct PreviewHost: View {
    @State private var query = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        WardrobeSearchPanelHeaderView(
            query: $query,
            isSearchFieldFocused: $isFocused
        )
    }
}
