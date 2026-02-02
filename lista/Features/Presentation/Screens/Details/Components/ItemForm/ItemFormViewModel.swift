//
//  ItemFormViewModel.swift
//  lista
//

import Combine
import Foundation
import PhotosUI
import SwiftUI
import UIKit

enum ItemFormMode {
    case read(ListaItemUiModel)
    case write(ItemFormContext)
}

enum ItemFormContext {
    case create(listId: String)
    case edit(ListaItemUiModel)
}

final class ItemFormViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var url: String = ""
    @Published var isCompleted: Bool = false
    @Published var updatedAt: Date? = nil
    @Published var galleryPickerSelection: PhotosPickerItem?
    @Published var image: UIImage?
    @Published var shouldRemoveImage: Bool = false
    @Published var isWriteMode: Bool = false
    @Published var createMore: Bool = false

    // MARK: - Private Properties
    private(set) var originalItem: ListaItemUiModel?
    private var listId: String?
    private var isEditMode: Bool = false

    // MARK: - Computed Properties
    var hasChanges: Bool {
        guard let original = originalItem else {
            // Creating new item - has changes if title is not empty
            return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return title != original.title ||
            description != (original.description ?? "") ||
            url != (original.url ?? "") ||
            isCompleted != original.isCompleted ||
            image != nil ||
            shouldRemoveImage
    }

    var isSubmitEnabled: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var navigationTitle: String {
        if isEditMode {
            return isWriteMode ? "Edit Item" : "Item Details"
        } else {
            return "Add Item"
        }
    }

    var isCreateMode: Bool {
        return isWriteMode && !isEditMode
    }

    // MARK: - Initialization
    func configure(mode: ItemFormMode) {
        switch mode {
        case .read(let item):
            isWriteMode = false
            isEditMode = true
            originalItem = item
            listId = item.listId
            loadItemData(item)

        case .write(let context):
            isWriteMode = true
            switch context {
            case .create(let id):
                isEditMode = false
                listId = id
                clearState()
            case .edit(let item):
                isEditMode = true
                originalItem = item
                listId = item.listId
                loadItemData(item)
            }
        }
    }

    // MARK: - State Management
    private func loadItemData(_ item: ListaItemUiModel) {
        self.title = item.title
        self.description = item.description ?? ""
        self.url = item.url ?? ""
        self.isCompleted = item.isCompleted
        self.updatedAt = item.updatedAt
        self.shouldRemoveImage = false
        self.galleryPickerSelection = nil
        
        if let imagePath = item.image {
            self.image = UIImage(contentsOfFile: imagePath)
        }
    }

    private func clearState() {
        title = ""
        description = ""
        url = ""
        isCompleted = false
        updatedAt = nil
        galleryPickerSelection = nil
        image = nil
        shouldRemoveImage = false
        createMore = false
    }

    func prepareForNextItem() {
        title = ""
        description = ""
        url = ""
        isCompleted = false
        updatedAt = nil
        galleryPickerSelection = nil
        image = nil
        shouldRemoveImage = false
        // Keep createMore as is so user preference is preserved
    }

    // MARK: - Actions
    func toggleEditMode() {
        isWriteMode.toggle()
    }

    func mergeStateForCreate() -> AddListaItemUiModel? {
        guard let listId = listId else { return nil }
        return AddListaItemUiModel(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            url: url.isEmpty ? nil : url.trimmingCharacters(in: .whitespacesAndNewlines),
            attachedImage: image
        )
    }

    func mergeStateForUpdate() -> UpdateListItemDTO? {
        guard let original = originalItem,
              let itemId = UUID(uuidString: original.id) else { return nil }

        return UpdateListItemDTO(
            itemId: itemId,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            url: url.isEmpty ? nil : url.trimmingCharacters(in: .whitespacesAndNewlines),
            isCompleted: isCompleted,
            image: image,
            shouldRemoveImage: shouldRemoveImage
        )
    }

    // MARK: - Image Handling
    func handleGallerySelection(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                    self.shouldRemoveImage = false
                    self.galleryPickerSelection = nil
                }
            }
        }
    }

    func removeImage() {
        image = nil
        shouldRemoveImage = true
    }

    func cancelImageRemoval() {
        shouldRemoveImage = false
        // Reload original image if exists
        if let original = originalItem, let imagePath = original.image {
            Task {
                if let loadedImage = try? DiskManager().loadImage(fileName: imagePath) {
                    await MainActor.run {
                        self.image = loadedImage
                    }
                }
            }
        }
    }
}
