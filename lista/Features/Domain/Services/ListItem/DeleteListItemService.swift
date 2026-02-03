//
//  DeleteListItemService.swift
//  lista
//

import Foundation

protocol DeleteListItemServiceProtocol {
    func deleteItem(itemId: String) async throws
}

final class DeleteListItemService: DeleteListItemServiceProtocol {
    private let repository: ListItemRepositoryProtocol

    init(repository: ListItemRepositoryProtocol) {
        self.repository = repository
    }

    func deleteItem(itemId: String) async throws {
        guard let itemUuid = UUID(uuidString: itemId) else {
            throw NSError(
                domain: "DeleteListItemService",
                code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Unable to parse UUID: \(itemId)"
                ]
            )
        }

        try await repository.deleteItem(itemId: itemUuid)
    }
}
