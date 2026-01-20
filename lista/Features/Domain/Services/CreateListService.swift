//
//  CreateListService.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Foundation

protocol CreateListServiceProtocol {
    func create(title: String) async throws -> Lista
}

final class CreateListService: CreateListServiceProtocol {

    private let repository: ListRepositoryProtocol

    init(repository: ListRepositoryProtocol) {
        self.repository = repository
    }

    func create(title: String) async throws -> Lista {
        return try await repository.createList(title: title)
    }
}
