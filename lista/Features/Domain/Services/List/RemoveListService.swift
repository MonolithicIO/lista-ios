//
//  RemoveListService.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Foundation

protocol RemoveListServiceProtocol {
    func remove(listId: String) async throws
}

final class RemoveListService: RemoveListServiceProtocol {
    private let repository: ListRepositoryProtocol

    init(repository: ListRepositoryProtocol) {
        self.repository = repository
    }

    func remove(listId: String) async throws {
        guard let listUuid = UUID(uuidString: listId) else {
            throw NSError(
                domain: "RemoveListService",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Invalid UUID"]
            )
        }

        try await repository.removeList(id: listUuid)
    }
}
