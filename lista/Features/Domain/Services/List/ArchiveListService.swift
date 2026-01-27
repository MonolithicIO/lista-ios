//
//  ArchiveListService.swift
//  lista
//
//  Created by Lucca Beurmann on 27/01/26.
//

import Foundation

protocol ArchiveListServiceProtocol {
    func archive(listaId: String, isArchived: Bool) async throws
}

final class ArchiveListService: ArchiveListServiceProtocol {

    private let repository: ListRepositoryProtocol

    init(repository: ListRepositoryProtocol) {
        self.repository = repository
    }

    func archive(listaId: String, isArchived: Bool) async throws {
        guard let listId = UUID(uuidString: listaId) else {
            throw NSError(domain: "Invalid UUID", code: 0, userInfo: nil)
        }

        return try await repository.setArchivedState(
            listaId: listId,
            isArchived: isArchived
        )
    }
}
