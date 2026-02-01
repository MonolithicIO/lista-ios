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

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var url: String = ""
    @State private var addMore: Bool = false
    @State private var isAddImagePromptVisible = false
    @State private var isGalleryPickerVisible = false
    @State private var galleryPickerSelection: PhotosPickerItem?
    @State private var image: UIImage?

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
                        text: $title,
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
                        text: $description,
                    )
                    .listRowBackground(AppColors.accent)
                }

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
                    },
                    content: {
                        HStack {
                            Button("Attach image") {
                                self.isAddImagePromptVisible = true
                            }
                            .confirmationDialog(
                                "",
                                isPresented: $isAddImagePromptVisible,
                                titleVisibility: .hidden
                            ) {
                                Button("Select from gallery") {
                                    isGalleryPickerVisible = true
                                }
                            }
                            .photosPicker(
                                isPresented: $isGalleryPickerVisible,
                                selection: $galleryPickerSelection,
                                matching: .images
                            )
                            Spacer()
                            if let imageToDisplay = self.image {
                                Image(uiImage: imageToDisplay)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 100, maxHeight: 100)
                            }
                        }
                        .listRowBackground(AppColors.accent)
                    }
                )
                .onChange(of: galleryPickerSelection) { oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(
                            type: Data.self
                        ),
                            let uiImage = UIImage(data: data)
                        {
                            self.image = uiImage
                        }
                    }
                }

                Toggle(
                    isOn: $addMore
                ) {
                    Text("Add more")
                        .foregroundStyle(AppColors.accentForeground)
                }
                .listRowBackground(AppColors.accent)
            }
            .interactiveDismissDisabled(true)
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
                            AddListaItemUiModel(
                                title: title,
                                description: description,
                                url: url
                            ),
                        )
                        if addMore {
                            clearState()
                            return
                        }
                        onDismiss()
                    }
                    .disabled(
                        title.trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                    )
                }
            }
        }
    }

    private func clearState() {
        title = ""
        description = ""
        url = ""
    }
}

#Preview {
    InsertItemView { item in

    } onDismiss: {

    }

}
