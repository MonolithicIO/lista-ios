//
//  ListRepository.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Foundation

protocol ListRepositoryProtocol {

    func fetchLists() async throws -> [Lista]
    func createList(title: String) async throws -> Lista
    func removeList(id: UUID) async throws

}

final class ListRepository: ListRepositoryProtocol {
    
    private let datasource: ListDataSourceProtocol
    
    init(datasource: ListDataSourceProtocol) {
        self.datasource = datasource
    }

    func fetchLists() async throws -> [Lista] {
        return try await datasource.fetchLists()
    }

    func createList(title: String) async throws  -> Lista {
        return try await datasource.createList(title: title)
    }

    func removeList(id: UUID) async throws {
        try await datasource.removeList(id: id)
    }

}
