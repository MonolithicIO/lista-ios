//
//  CreateListService.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Foundation

protocol CreateListServiceProtocol {
    func create(title: String) async -> List
}

final class CreateListService: CreateListServiceProtocol {

    private let repository: ListRepositoryProtocol

    init(repository: ListRepositoryProtocol) {
        self.repository = repository
    }

    func create(title: String) async -> List {
        return await repository.createList(title: title)
    }
}
