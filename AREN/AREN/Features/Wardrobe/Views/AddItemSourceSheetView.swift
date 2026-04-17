//
//  AddItemSourceSheetView 2.swift
//  AREN
//
//  Created by Ayusman sahu on 12/04/26.
//


import SwiftUI
import PhotosUI

// MARK: - Add Item Source Sheet
// Matches WardrobeFilterPanelView pattern — ZStack overlay, owned by AppShellView

struct AddItemSourceSheetView: View {
    @Binding var isPresented: Bool
    var onImageSelected: (UIImage) -> Void

    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                sourceRow(label: "CAMERA") {
                    showCamera = true
                }

                sourceRow(label: "BROWSE") {
                    showPhotoPicker = true
                }

                sourceRow(label: "PRODUCT CODE") {
                    // Logic deferred — UI only
                }
            }
            .frame(maxWidth: Layout.optionsWidth)
            .frame(maxWidth: .infinity)
            .padding(Layout.contentInset)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: Layout.sheetHeight)
        .background(ArenColor.Surface.primary)
        // Camera
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView { image in
                showCamera = false
                isPresented = false
                onImageSelected(image)
            }
            .ignoresSafeArea()
        }
        // Photo library
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        showPhotoPicker = false
                        isPresented = false
                        onImageSelected(image)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func sourceRow(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Spacer(minLength: 0)

                Text(label)
                    .font(labelFont)
                    .kerning(0)
                    .foregroundStyle(ArenColor.Text.primary)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Layout.optionHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var labelFont: Font {
        let candidates = [
            "HelveticaNowText-Light",
            "HelveticaNowText Light",
            "HelveticaNowText-Regular"
        ]

        for name in candidates where UIFont(name: name, size: 13) != nil {
            return .custom(name, size: 13)
        }

        return .system(size: 13, weight: .light)
    }
}

private enum Layout {
    static let contentInset: CGFloat = 20
    static let optionsWidth: CGFloat = 207.04
    static let optionHeight: CGFloat = 32
    static let sheetHeight: CGFloat = 136
}
