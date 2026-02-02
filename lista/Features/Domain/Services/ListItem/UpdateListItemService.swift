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

    init(repository: ListItemRepositoryProtocol) {
        self.repository = repository
    }

    func update(item: UpdateListItemDTO) async throws -> ListaItem {
        return try await repository.updateItem(item: item)
    }
}
