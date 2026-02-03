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

    init(listItemRepository: ListItemRepositoryProtocol) {
        self.listItemRepository = listItemRepository
    }

    func create(item _dto: CreateListItemDTO) async throws -> ListaItem {
        return try await listItemRepository.createItem(item: _dto)
    }
}
