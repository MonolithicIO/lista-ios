//
//  FetchListsService.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Foundation

protocol FetchListsServiceProtocol {
    func fetch() async -> [List]
}

final class FetchListsService: FetchListsServiceProtocol {
    private let repository: ListRepositoryProtocol

    init(repository: ListRepositoryProtocol) {
        self.repository = repository
    }

    func fetch() async -> [List] {
        return await repository.fetchLists()
    }
}
