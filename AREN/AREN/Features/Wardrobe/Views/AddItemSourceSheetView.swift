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
        ZStack(alignment: .bottom) {
           
            VStack(spacing: 0) {
                // CAMERA
                sourceRow(label: "CAMERA") {
                    showCamera = true
                }

                Divider()
                    .background(Color(hex: "#E8E8E6"))

                // BROWSE
                sourceRow(label: "BROWSE") {
                    showPhotoPicker = true
                }

                Divider()
                    .background(Color(hex: "#E8E8E6"))

                // PRODUCT CODE
                sourceRow(label: "PRODUCT CODE") {
                    // Logic deferred — UI only
                }
            }
            .background(Color.white)
        }
        .ignoresSafeArea()
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
            HStack {
                Text(label)
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
