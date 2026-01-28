//
//  RevertCompleteService.swift
//  lista
//
//  Created by Lucca Beurmann on 28/01/26.
//

import Foundation

protocol RevertCompleteServiceProtocol {
    func revert(listaId: String) async throws
}

final class RevertCompleteService: RevertCompleteServiceProtocol {

    private let repository: ListRepositoryProtocol

    init(repository: ListRepositoryProtocol) {
        self.repository = repository
    }

    func revert(listaId: String) async throws {
        guard let id = UUID(uuidString: listaId) else {
            throw NSError(domain: "Invalid UUID", code: 0, userInfo: nil)
        }

        return try await repository.setCompletedState(listaid: id, isCompleted: false)
    }
}

