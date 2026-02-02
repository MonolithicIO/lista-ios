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
    @State var presentation: InsertItemView.ImagePresentation? = nil

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
                    presentation: $presentation,
                    galleryPickerSelection: $viewModel.galleryPickerSelection,
                    selectedImage: $viewModel.image
                )
                .onChange(of: viewModel.galleryPickerSelection) {
                    oldValue,
                    newValue in
                    viewModel.handleGallerySelection(newValue)
                    presentation = nil
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
        }
    }
}

extension InsertItemView {
    enum ImagePresentation {
        case gallery
        case camera
        case prompt
    }
}

private struct InsertItemImageView: View {
    @Binding var presentation: InsertItemView.ImagePresentation?
    @Binding var galleryPickerSelection: PhotosPickerItem?
    @Binding var selectedImage: UIImage?

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
                        presentation = .prompt
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
                        isPresented: .constant(presentation == .prompt),
                        titleVisibility: .hidden
                    ) {
                        Button("Select from gallery") {
                            presentation = .gallery
                        }

                        Button("Take photo") {
                            presentation = .camera
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
        .photosPicker(
            isPresented: Binding(
                get: { presentation == .gallery },
                set: { isPresented in
                    if !isPresented {
                        presentation = nil
                    }
                }
            ),
            selection: $galleryPickerSelection,
            matching: .images
        )
        .fullScreenCover(
            isPresented: Binding(
                get: { presentation == .camera },
                set: { isPresented in
                    if !isPresented {
                        presentation = nil
                    }
                }
            )
        ) {
            CameraPickerView(
                onImagePicked: { uiImage in
                    selectedImage = uiImage
                    presentation = nil
                }
            )
        }
    }
}

#Preview {
    InsertItemView { item in

    } onDismiss: {

    }

}
