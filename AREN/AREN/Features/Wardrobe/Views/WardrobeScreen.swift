//
//  WardrobeScreen.swift
//  AREN
//

import SwiftUI
import Kingfisher

struct WardrobeScreen: View {
    #if DEBUG
    private let showDebugBorders = false
    #else
    private let showDebugBorders = false
    #endif

    let onFiltersTap: () -> Void
    let onSearchTap: () -> Void
    let onAddTap: () -> Void

    @ObservedObject var viewModel: WardrobeViewModel
    @State private var selectedCategory = "All"

    private let columns = [
        GridItem(.fixed(171), spacing: 20),
        GridItem(.fixed(171), spacing: 20)
    ]

    init(
        viewModel: WardrobeViewModel,
        onFiltersTap: @escaping () -> Void = {},
        onSearchTap: @escaping () -> Void = {},
        onAddTap: @escaping () -> Void = {}
    ) {
        self.viewModel = viewModel
        self.onFiltersTap = onFiltersTap
        self.onSearchTap = onSearchTap
        self.onAddTap = onAddTap
    }

    var body: some View {
        VStack(spacing: 0) {
            WardrobeTopNavView(
                mode: .filtersSearchAdd,
                showsBackButton: false,
                onFiltersTap: onFiltersTap,
                onSearchTap: onSearchTap,
                onAddTap: onAddTap
            )
            .debugBorder(if: showDebugBorders, color: .orange)

            WardrobeTabToggleView(
                selectedTab: $viewModel.activeTab,
                itemCount: viewModel.filteredItems.count,
                outfitCount: viewModel.filteredOutfits.count
            )
            .onChange(of: viewModel.activeTab) {
                selectedCategory = "All"
            }
            .debugBorder(if: showDebugBorders, color: .blue)

            WardrobeCategoryFilterStripView(
                selectedCategory: selectedCategory,
                tab: viewModel.activeTab
            ) { category in
                selectedCategory = category
            }
            .debugBorder(if: showDebugBorders, color: .green)

            ScrollView(.vertical, showsIndicators: false) {
                if viewModel.activeTab == .items {
                    itemsGrid
                } else {
                    outfitsGrid
                }
            }
            .debugBorder(if: showDebugBorders, color: .purple)
        }
        .background(ArenColor.Surface.primary)
        .task {
            await viewModel.fetchItems()
            await viewModel.fetchOutfits()
        }
        .debugBorder(if: showDebugBorders, color: .red)
    }

    // MARK: - Items Grid

    private var itemsGrid: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 32) {
            ForEach(categoryFilteredItems) { item in
                WardrobeItemCell(item: item)
                    .debugBorder(if: showDebugBorders, color: .pink)
            }
        }
        .padding(.horizontal, 20)
        .debugBorder(if: showDebugBorders, color: .cyan)
    }

    // MARK: - Outfits Grid

    private var outfitsGrid: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 32) {
            ForEach(viewModel.filteredOutfits) { outfit in
                WardrobeOutfitCell(outfit: outfit, onTap: {})
                    .debugBorder(if: showDebugBorders, color: .pink)
            }
        }
        .padding(.horizontal, 20)
        .debugBorder(if: showDebugBorders, color: .mint)
    }

    // MARK: - Category Filter (applied on top of ViewModel filter)

    private var categoryFilteredItems: [WardrobeItem] {
        guard selectedCategory.caseInsensitiveCompare("all") != .orderedSame else {
            return viewModel.filteredItems
        }
        return viewModel.filteredItems.filter {
            ($0.category ?? "").caseInsensitiveCompare(selectedCategory) == .orderedSame
        }
    }
}

#Preview {
    WardrobeScreen(viewModel: WardrobeViewModel())
}
