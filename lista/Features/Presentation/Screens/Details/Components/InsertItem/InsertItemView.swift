//
//  InsertItemView.swift
//  lista
//
//  Created by Lucca Beurmann on 26/01/26.
//

import Foundation
import PhotosUI
import SwiftUI

struct InsertItemView: View {
    let onSubmit: (AddListaItemUiModel) -> Void
    let onDismiss: () -> Void

    @StateObject private var viewModel: InsertItemViewModel =
        InsertItemViewModel()

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
                    galleryPickerSelection: $viewModel.galleryPickerSelection,
                    selectedImage: viewModel.image,
                    onClearImage: viewModel.onClearImage,
                    onSelectImage: { image in viewModel.image = image }
                )
                .onChange(of: viewModel.galleryPickerSelection) {
                    oldValue,
                    newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(
                            type: Data.self
                        ),
                            let uiImage = UIImage(data: data)
                        {
                            viewModel.image = uiImage
                            viewModel.galleryPickerSelection = nil
                        }
                    }
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
                            self.viewModel.mergeState()
                        )
                        if viewModel.addMore {
                            viewModel.clearState()
                        }
                        onDismiss()
                    }
                    .disabled(viewModel.isSubmitEnabled)
                }
            }
        }
    }
}

private struct InsertItemImageView: View {
    @State private var isAddImagePromptVisible = false
    @State private var isGalleryPickerVisible = false
    @State private var isCameraPickerVisible: Bool = false
    @Binding var galleryPickerSelection: PhotosPickerItem?
    let selectedImage: UIImage?
    let onClearImage: () -> Void
    let onSelectImage: (UIImage) -> Void

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
                        isAddImagePromptVisible = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Attach image")
                                    .font(.headline)

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
                                onClearImage()
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
        .confirmationDialog(
            "",
            isPresented: $isAddImagePromptVisible,
            titleVisibility: .hidden
        ) {
            Button("Select from gallery") {
                isGalleryPickerVisible = true
            }

            Button("Take photo") {
                isCameraPickerVisible = true
            }
        }
        .photosPicker(
            isPresented: $isGalleryPickerVisible,
            selection: $galleryPickerSelection,
            matching: .images
        )
        .fullScreenCover(isPresented: $isCameraPickerVisible) {
            CameraPickerView { uiImage in
                onSelectImage(uiImage)
            }
        }

    }
}

#Preview {
    InsertItemView { item in

    } onDismiss: {

    }

}
