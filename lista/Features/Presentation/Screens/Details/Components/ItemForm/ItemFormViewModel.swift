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
    @Published var isWriteMode: Bool = false
    @Published var createMore: Bool = false
    @Published var didImageChanged: Bool = false

    // MARK: - Private Properties
    private(set) var originalItem: ListaItemUiModel?
    private(set) var isEditMode: Bool = false
    private var listId: String?

    // MARK: - Computed Properties
    var hasChanges: Bool {
        guard let original = originalItem else {
            // Creating new item - has changes if title is not empty
            return !title.trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
        }
        let titleDiff = title != original.title
        let descriptionDiff = description != (original.description ?? "")
        let urlDiff = url != (original.url ?? "")
        let completionDiff = isCompleted != original.isCompleted

        return titleDiff || descriptionDiff || urlDiff || completionDiff
            || didImageChanged

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
        self.didImageChanged = false
        self.galleryPickerSelection = nil

        if let imagePath = item.image {
            self.image = UIImage(contentsOfFile: imagePath)
        }
    }

    func clearState() {
        title = ""
        description = ""
        url = ""
        isCompleted = false
        updatedAt = nil
        galleryPickerSelection = nil
        image = nil
        didImageChanged = false
        createMore = false
    }

    // MARK: - Actions
    func toggleEditMode() {
        isWriteMode.toggle()
    }

    func mergeStateForCreate() -> AddListaItemUiModel? {
        if listId == nil { return nil }

        return AddListaItemUiModel(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty
                ? nil
                : description.trimmingCharacters(in: .whitespacesAndNewlines),
            url: url.isEmpty
                ? nil : url.trimmingCharacters(in: .whitespacesAndNewlines),
            attachedImage: image
        )
    }

    func mergeStateForUpdate() -> UpdateListItemDTO? {
        guard let original = originalItem,
            let itemId = UUID(uuidString: original.id)
        else { return nil }

        return UpdateListItemDTO(
            itemId: itemId,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty
                ? nil
                : description.trimmingCharacters(in: .whitespacesAndNewlines),
            url: url.isEmpty
                ? nil : url.trimmingCharacters(in: .whitespacesAndNewlines),
            isCompleted: isCompleted,
            image: image,
            shouldRemoveImage: didImageChanged
        )
    }

    // MARK: - Image Handling
    func handleGallerySelection(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            {
                await MainActor.run {
                    self.image = image
                    self.didImageChanged = true
                    self.galleryPickerSelection = nil
                }
            }
        }
    }
}
