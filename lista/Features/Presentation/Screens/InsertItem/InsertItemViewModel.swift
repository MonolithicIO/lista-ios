//
//  InsertItemViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Combine
import Foundation
import PhotosUI
import SwiftUI

@MainActor
@Observable
final class InsertItemViewModel {
    // MARK: - Dependency properties
    private let createItemService: CreateListItemServiceProtocol
    private let getItemService: GetListItemServiceProtocol
    private let updateListItemService: UpdateListItemServiceProtocol

    // MARK: - Initializer
    init(
        createItemService: CreateListItemServiceProtocol,
        getItemService: GetListItemServiceProtocol,
        updateListItemService: UpdateListItemServiceProtocol
    ) {
        self.createItemService = createItemService
        self.getItemService = getItemService
        self.updateListItemService = updateListItemService
    }

    // MARK: - Public State
    var title: String = ""
    var description: String = ""
    var url: String = ""
    var isCompleted: Bool = false
    var selectedImage: UIImage?
    var isEditing: Bool = false
    var event: Events? = nil
    var galleryPickerSelection: PhotosPickerItem?
    var isAddMoreEnabled: Bool = false

    var isUrlInvalid: Bool {
        !isValidUrlInput(url)
    }

    // MARK: - Private State
    private var originalItem: ListaItemUiModel?

    func initialize(itemId: String?) {
        if let itemId {
            loadItemData(itemId: itemId)
            isEditing = true
        }
    }

    func insertItem(listId: String) {
        guard !isUrlInvalid else { return }
        guard let uuid = UUID(uuidString: listId) else { return }

        if isEditing {
            guard let originalItemId = originalItem?.id else { return }
            guard let originalItemUuid = UUID(uuidString: originalItemId) else {
                return
            }

            updateItem(itemId: originalItemUuid)
        } else {
            createNewItem(listId: uuid)
        }
    }

    func handleGallerySelection(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            {
                await MainActor.run {
                    self.selectedImage = image
                    self.galleryPickerSelection = nil
                }
            }
        }
    }

    private func createNewItem(listId: UUID) {
        Task {
            do {
                _ = try await createItemService.create(
                    item: CreateListItemDTO(
                        listId: listId,
                        title: self.title,
                        description: sanitizeString(input: self.description),
                        url: sanitizeUrl(input: self.url),
                        image: self.selectedImage
                    )
                )

                if isAddMoreEnabled {
                    clearState()
                } else {
                    event = .onSuccess
                }
            } catch {
                print("Failed to create item \(error)")
            }
        }
    }

    private func updateItem(
        itemId: UUID,
    ) {
        Task {
            do {
                _ = try await updateListItemService.update(
                    item: UpdateListItemDTO(
                        itemId: itemId,
                        title: self.title,
                        description: sanitizeString(input: self.description),
                        url: sanitizeUrl(input: self.url),
                        isCompleted: self.isCompleted,
                        image: self.selectedImage,
                        shouldRemoveImage: false
                    )
                )
                event = .onSuccess

            } catch {
                print("Failed to create item \(error)")
            }
        }
    }

    private func loadItemData(itemId: String) {
        Task {
            do {
                let item = try await getItemService.get(id: itemId)

                await MainActor.run {
                    title = item.title
                    description = item.description ?? ""
                    url = item.url ?? ""
                    isCompleted = item.isCompleted
                    originalItem = item.toUiModel()
                }

                // Load image asynchronously on background thread
                if let imagePath = item.imageUrl {
                    let image = await Task.detached {
                        UIImage(contentsOfFile: imagePath)
                    }.value
                    await MainActor.run {
                        selectedImage = image
                    }
                }
            } catch {
                print("Failed to fetch item details \(error)")
            }
        }
    }

    private func sanitizeString(input: String?) -> String? {
        guard let filledInput = input else { return nil }

        if filledInput.isEmpty {
            return nil
        }

        return filledInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func sanitizeUrl(input: String?) -> String? {
        guard let input else { return nil }

        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedInput.isEmpty {
            return nil
        }

        return normalizedUrlString(trimmedInput)
    }

    private func isValidUrlInput(_ input: String) -> Bool {
        guard let normalizedUrl = sanitizeUrl(input: input) else { return true }

        guard let urlComponents = URLComponents(string: normalizedUrl),
            let scheme = urlComponents.scheme?.lowercased(),
            ["http", "https"].contains(scheme),
            let host = urlComponents.host,
            !host.isEmpty
        else {
            return false
        }

        return true
    }

    private func normalizedUrlString(_ input: String) -> String {
        if input.contains("://") {
            return input
        }

        return "http://\(input)"
    }

    private func clearState() {
        self.title = ""
        self.description = ""
        self.url = ""
        self.isCompleted = false
        self.selectedImage = nil
        self.event = nil
        self.galleryPickerSelection = nil
    }

}

extension InsertItemViewModel {
    enum Events {
        case onSuccess
    }
}
