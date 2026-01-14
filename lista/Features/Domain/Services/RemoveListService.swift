//
//  RemoveListService.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Foundation

protocol RemoveListServiceProtocol {
    func remove(id: UUID) async
}

final class RemoveListService: RemoveListServiceProtocol {
    private let repository: ListRepositoryProtocol

    init(repository: ListRepositoryProtocol) {
        self.repository = repository
    }

    func remove(id: UUID) async {
        await repository.removeList(id: id)
    }
}
