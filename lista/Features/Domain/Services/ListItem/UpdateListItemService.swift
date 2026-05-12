//
//  UpdateListItemService.swift
//  lista
//

import Foundation

protocol UpdateListItemServiceProtocol {
    func update(item: UpdateListItemDTO) async throws -> ListaItem
}

final class UpdateListItemService: UpdateListItemServiceProtocol {
    private let repository: ListItemRepositoryProtocol
    private let diskManager: DiskManagerProtocol
    private let uuidProvider: UUIDProviderProtocol

    init(
        repository: ListItemRepositoryProtocol,
        diskManager: DiskManagerProtocol,
        uuidProvider: UUIDProviderProtocol
    ) {
        self.repository = repository
        self.diskManager = diskManager
        self.uuidProvider = uuidProvider
    }

    func update(item: UpdateListItemDTO) async throws -> ListaItem {
        let itemToUpdate = try await repository.getItem(itemId: item.itemId)
        var newImagePath: String?

        if let newImage = item.itemImage {
            newImagePath = try diskManager.saveImage(
                image: newImage,
                fileName: uuidProvider.provide().uuidString
            )
        }

        // Existe o edge case onde o delete da imagem antiga falhe, o que executaria o catch e também deletaria a imagem nova. Improvável que aconteça, mas caso aconteça, foi intencionalmente não tratado.
        do {
            let updatedItem = try await repository.updateItem(
                item: UpdateListItemRequest(
                    itemId: item.itemId,
                    title: item.title,
                    description: item.description,
                    url: item.url,
                    isCompleted: item.isCompleted,
                    itemImagePath: newImagePath
                )
            )
            if let imageToDelete = itemToUpdate.imageUrl {
                try diskManager.deleteImage(fileName: imageToDelete)
            }
            return updatedItem

        } catch {
            if let newImagePath {
                try diskManager.deleteImage(fileName: newImagePath)
            }
            throw error
        }
    }
}
