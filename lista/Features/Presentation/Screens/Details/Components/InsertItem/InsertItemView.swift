//
//  InsertItemView.swift
//  lista
//
//  Created by Lucca Beurmann on 26/01/26.
//

import Foundation
import PhotosUI
import SwiftUI
import UIKit

// MARK: - UI State
enum ImageSource {
    case gallery
    case camera
}

// MARK: - Main View
struct InsertItemView: View {
    let onSubmit: (AddListaItemUiModel) -> Void
    let onDismiss: () -> Void

    @StateObject private var viewModel: InsertItemViewModel =
        InsertItemViewModel()

    @State var imagePickerSource: ImageSource? = nil

    var body: some View {
        NavigationStack {
            List {
                Section(
                    header: Text("Title").foregroundStyle(
                        AppColors.foreground
                    )
                ) {
                    TextField(
                        "Something cool",
                        text: $viewModel.title,
                    )
                    .listRowBackground(AppColors.accent)
                }

                Section(
                    header: HStack {
                        Text("Description").foregroundStyle(
                            AppColors.foreground
                        )
                        Spacer()
                        Text("Optional").foregroundStyle(
                            AppColors.mutedForeground
                        )
                        .font(.caption)
                    }
                ) {
                    TextField(
                        "Extra notes",
                        text: $viewModel.description,
                    )
                    .listRowBackground(AppColors.accent)
                }

                InsertItemImageView(
                    onImageSourceSelected: { source in
                        imagePickerSource = source
                    },
                    galleryPickerSelection: $viewModel.galleryPickerSelection,
                    selectedImage: $viewModel.image
                )
                .onChange(of: viewModel.galleryPickerSelection) {
                    oldValue,
                    newValue in
                    viewModel.handleGallerySelection(newValue)
                }

                Toggle(
                    isOn: $viewModel.addMore
                ) {
                    Text("Add more")
                        .foregroundStyle(AppColors.accentForeground)
                }
                .listRowBackground(AppColors.accent)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSubmit(
                            viewModel.mergeState()
                        )
                        if viewModel.addMore {
                            viewModel.clearState()
                        }
                        onDismiss()
                    }
                    .disabled(viewModel.isSubmitEnabled)
                }
            }
            .photosPicker(
                isPresented: Binding(
                    get: { imagePickerSource == .gallery },
                    set: { isPresented in
                        if !isPresented {
                            imagePickerSource = nil
                        }
                    }
                ),
                selection: $viewModel.galleryPickerSelection,
                matching: .images
            )
            .fullScreenCover(
                isPresented: Binding(
                    get: { imagePickerSource == .camera },
                    set: { isPresented in
                        if !isPresented {
                            imagePickerSource = nil
                        }
                    }
                )
            ) {
                CameraPickerView(
                    onImagePicked: { uiImage in
                        viewModel.image = uiImage
                        imagePickerSource = nil
                    }
                )
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Select Image View
private struct InsertItemImageView: View {
    let onImageSourceSelected: (ImageSource) -> Void
    @Binding var galleryPickerSelection: PhotosPickerItem?
    @Binding var selectedImage: UIImage?
    
    @State private var isConfirmationDialogPresented: Bool = false

    var body: some View {
        Section(
            header: HStack {
                Text("Image").foregroundStyle(
                    AppColors.foreground
                )
                Spacer()
                Text("Optional").foregroundStyle(
                    AppColors.mutedForeground
                )
                .font(.caption)
            }
        ) {
            VStack(spacing: 12) {
                if selectedImage == nil {
                    Button {
                        isConfirmationDialogPresented = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.title3)
                                .foregroundStyle(AppColors.blue)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Attach image")
                                    .font(.headline)
                                    .foregroundStyle(AppColors.blue)

                                Text("Gallery or camera")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.mutedForeground)
                            }

                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 1, dash: [5])
                                )
                                .foregroundStyle(AppColors.mutedForeground)
                        )
                    }
                    .confirmationDialog(
                        "",
                        isPresented: $isConfirmationDialogPresented,
                        titleVisibility: .hidden
                    ) {
                        Button("Select from gallery") {
                            onImageSourceSelected(.gallery)
                        }

                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button("Take photo") {
                                onImageSourceSelected(.camera)
                            }
                        }
                    }
                }

                if let image = selectedImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .clipped()

                        Button {
                            withAnimation {
                                selectedImage = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .background(.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(8)
                    }
                }
            }
            .padding(.vertical, 8)
            .listRowBackground(AppColors.accent)
        }
    }
}

#Preview {
    InsertItemView { item in

    } onDismiss: {

    }

}
