//
//  ItemFormView.swift
//  lista
//

import Foundation
import PhotosUI
import SafariServices
import SwiftUI
import UIKit

enum ItemFormImageSource {
    case gallery
    case camera
}

struct ItemFormView: View {
    let mode: ItemFormMode
    let isParentListCompleted: Bool
    let onCreate: ((AddListaItemUiModel) -> Void)?
    let onUpdate: ((UpdateListItemDTO) -> Void)?
    let onDismiss: () -> Void

    @StateObject private var viewModel: ItemFormViewModel = ItemFormViewModel()
    @State private var imagePickerSource: ItemFormImageSource? = nil
    @State private var showSafari: Bool = false

    var navigationTitle: String {
        if viewModel.isEditMode {
            return viewModel.isWriteMode ? "Edit Item" : "Item Details"
        } else {
            return "Add Item"
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.isWriteMode, let updatedAt = viewModel.updatedAt {
                    LastUpdatedView(date: updatedAt)
                        .listRowBackground(Color.clear)
                        .listRowInsets(
                            .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                        )
                        .listRowSeparator(.hidden)
                }

                ItemStatusBadge(
                    isItemCompleted: viewModel.isCompleted,
                )
                .listRowBackground(Color.clear)
                .listRowInsets(
                    .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                )

                ItemTitleSectionView(
                    isWriteMode: viewModel.isWriteMode,
                    title: $viewModel.title
                )

                // Status Toggle - Only shown in write mode when editing existing items
                if viewModel.isWriteMode && !viewModel.isCreateMode {
                    ItemStatusSwitchView(
                        isCompleted: $viewModel.isCompleted
                    )
                }

                // Description Section - Only shown if has content or in write mode
                if viewModel.isWriteMode || !viewModel.description.isEmpty {
                    ItemDescriptionSectionView(
                        isWriteMode: viewModel.isWriteMode,
                        description: $viewModel.description
                    )
                }

                // URL Section - Only shown if has content or in write mode
                if viewModel.isWriteMode || !viewModel.url.isEmpty {
                    ItemUrlSectionView(
                        isWriteMode: viewModel.isWriteMode,
                        showSafari: $showSafari,
                        url: $viewModel.url
                    )
                }

//                ItemFormImageSection(
//                    isWriteMode: viewModel.isWriteMode,
//                    formImageSource: $imagePickerSource,
//                    imageToDisplay: $viewModel.image
//                )

                // Create More Toggle - Only shown when creating new items
                if viewModel.isCreateMode {
                    Section {
                        Toggle(isOn: $viewModel.createMore) {
                            HStack {
                                Image(
                                    systemName: viewModel.createMore
                                        ? "checkmark.circle.fill" : "circle"
                                )
                                .foregroundStyle(
                                    viewModel.createMore
                                        ? AppColors.green
                                        : AppColors.mutedForeground
                                )
                                Text("Create another")
                                    .foregroundStyle(AppColors.foreground)
                            }
                        }
                    }
                    .listRowBackground(AppColors.accent)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isWriteMode {
                        // Save button in write mode
                        Button("Save") {
                            saveAction()
                        }
                        .disabled(!viewModel.hasChanges)
                    } else {
                        // Edit button in read mode
                        Button("Edit") {
                            withAnimation {
                                viewModel.toggleEditMode()
                            }
                        }
                    }
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
            .onChange(of: viewModel.galleryPickerSelection) { _, newValue in
                viewModel.handleGallerySelection(newValue)
            }
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
                        viewModel.didImageChanged = true
                        imagePickerSource = nil
                    }
                )
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showSafari) {
                if let url = URL(string: viewModel.url),
                    UIApplication.shared.canOpenURL(url)
                {
                    SafariView(url: url)
                }
            }
            .onAppear {
                viewModel.configure(mode: mode)
            }
        }
    }

    private func saveAction() {
        switch mode {
        case .read, .write(.edit):
            // Update existing item
            if let dto = viewModel.mergeStateForUpdate() {
                onUpdate?(dto)
            }
            onDismiss()
        case .write(.create):
            // Create new item
            if let newItem = viewModel.mergeStateForCreate() {
                onCreate?(newItem)
                if viewModel.createMore {
                    viewModel.clearState()
                } else {
                    // Dismiss the view
                    onDismiss()
                }
            }
        }
    }
}

#Preview("Create Mode") {
    ItemFormView(
        mode: .write(.create(listId: "123")),
        isParentListCompleted: false,
        onCreate: { _ in },
        onUpdate: nil,
        onDismiss: {}
    )
}

#Preview("Read Mode - Active List") {
    ItemFormView(
        mode: .read(
            ListaItemUiModel(
                listId: "123",
                id: UUID().uuidString,
                title: "Sample Item",
                description: "A sample description",
                url: "https://example.com",
                isCompleted: false,
                image: nil,
                updatedAt: Date()
            )
        ),
        isParentListCompleted: false,
        onCreate: nil,
        onUpdate: { _ in },
        onDismiss: {}
    )
}

#Preview("Read Mode - Completed List") {
    ItemFormView(
        mode: .read(
            ListaItemUiModel(
                listId: "123",
                id: UUID().uuidString,
                title: "Sample Item",
                description: "A sample description",
                url: "https://example.com",
                isCompleted: false,
                image: nil,
                updatedAt: nil
            )
        ),
        isParentListCompleted: true,
        onCreate: nil,
        onUpdate: { _ in },
        onDismiss: {}
    )
}

#Preview("Edit Mode") {
    ItemFormView(
        mode: .write(
            .edit(
                ListaItemUiModel(
                    listId: "123",
                    id: UUID().uuidString,
                    title: "Sample Item",
                    description: "A sample description",
                    url: "https://example.com",
                    isCompleted: false,
                    image: nil,
                    updatedAt: nil
                )
            )
        ),
        isParentListCompleted: false,
        onCreate: nil,
        onUpdate: { _ in },
        onDismiss: {}
    )
}
