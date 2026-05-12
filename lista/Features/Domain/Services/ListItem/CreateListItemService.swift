//
//  CreateListItemService.swift
//  lista
//
//  Created by Lucca Beurmann on 21/01/26.
//

import Foundation

protocol CreateListItemServiceProtocol {
    func create(item dto: CreateListItemDTO) async throws -> ListaItem
}

final class CreateListItemService: CreateListItemServiceProtocol {

    private let listItemRepository: ListItemRepositoryProtocol
    private let diskManager: DiskManagerProtocol
    private let uuidProvider: UUIDProviderProtocol

    init(
        listItemRepository: ListItemRepositoryProtocol,
        diskManager: DiskManagerProtocol,
        uuidProvider: UUIDProviderProtocol
    ) {
        self.listItemRepository = listItemRepository
        self.diskManager = diskManager
        self.uuidProvider = uuidProvider
    }

    func create(item _dto: CreateListItemDTO) async throws -> ListaItem {
        var savedImageUrl: String?

        if let itemImage = _dto.image {
            savedImageUrl = try diskManager.saveImage(
                image: itemImage,
                fileName: uuidProvider.provide().uuidString
            )
        }

        do {
            return try await listItemRepository.createItem(
                item: CreateListItemRequest(
                    listId: _dto.listId,
                    title: _dto.title,
                    description: _dto.description,
                    url: _dto.url,
                    imagePath: savedImageUrl
                )
            )
        } catch {
            if let imageToDelete = savedImageUrl {
                try diskManager.deleteImage(fileName: imageToDelete)
            }
            throw error
        }
    }
}
