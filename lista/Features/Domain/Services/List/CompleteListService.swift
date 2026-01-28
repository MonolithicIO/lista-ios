//
//  CompleteListService.swift
//  lista
//
//  Created by Lucca Beurmann on 28/01/26.
//

import Foundation

protocol CompleteListServiceProtocol {
    func complete(listaId: String) async throws
}

final class CompleteListService: CompleteListServiceProtocol {

    private let repository: ListRepositoryProtocol

    init(repository: ListRepositoryProtocol) {
        self.repository = repository
    }

    func complete(listaId: String) async throws {
        guard let id = UUID(uuidString: listaId) else {
            throw NSError(domain: "Invalid UUID", code: 0, userInfo: nil)
        }

        return try await repository.setCompletedState(listaid: id, isCompleted: true)
    }
}

