//
//  AddItemCategorySheetView.swift
//  AREN
//
//  Created by Ayusman sahu on 12/04/26.
//

//
//  AddItemCategory.swift
//  AREN
//
//  Created by Ayusman sahu on 12/04/26.
//


import SwiftUI

// MARK: - Add Item Category Sheet
// Appears after image is selected. Same pattern as AddItemSourceSheetView.

enum AddItemCategory: String, CaseIterable {
    case top    = "TOP"
    case bottom = "BOTTOM"
    case shoes  = "SHOES"
}

struct AddItemCategorySheetView: View {

    @Binding var isPresented: Bool
    let image: UIImage
    var onCategorySelected: (UIImage, AddItemCategory) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                ForEach(Array(AddItemCategory.allCases.enumerated()), id: \.element) { index, category in
                    categoryRow(category)

                    if index < AddItemCategory.allCases.count - 1 {
                        Divider()
                            .background(Color(hex: "#E8E8E6"))
                    }
                }
            }
            .background(Color.white)
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func categoryRow(_ category: AddItemCategory) -> some View {
        Button {
            isPresented = false
            onCategorySelected(image, category)
        } label: {
            HStack {
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .regular))
                    .tracking(1.2)
                    .foregroundColor(Color(hex: "#1A1A1A"))
                Spacer()
            }
            .padding(.horizontal, 24)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
    }
}
