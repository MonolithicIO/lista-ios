//
//  ListItemRepository.swift
//  lista
//
//  Created by Lucca Beurmann on 21/01/26.
//

import Foundation

protocol ListItemRepositoryProtocol {
    func createItem(item _dto: CreateListItemDTO) async throws -> ListaItem
    func updateStatus(itemId: UUID, isActive: Bool) async throws -> ListaItem
    func updateItem(item: UpdateListItemDTO) async throws -> ListaItem
    func deleteItem(itemId: UUID) async throws
}

final class ListItemRepository: ListItemRepositoryProtocol {

    private let datasource: ListItemDataSourceProtocol

    init(datasource: ListItemDataSourceProtocol) {
        self.datasource = datasource
    }

    func createItem(item _dto: CreateListItemDTO) async throws -> ListaItem {
        return try await datasource.createItem(item: _dto)
    }

    func updateStatus(itemId: UUID, isActive: Bool) async throws -> ListaItem {
        return try await datasource.updateStatus(
            itemId: itemId,
            isActive: isActive
        )
    }

    func updateItem(item: UpdateListItemDTO) async throws -> ListaItem {
        return try await datasource.updateItem(item: item)
    }

    func deleteItem(itemId: UUID) async throws {
        try await datasource.deleteItem(itemId: itemId)
    }
}
