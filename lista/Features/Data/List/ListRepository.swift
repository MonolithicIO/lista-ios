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
    func fetchListDetails (listaId _id: UUID) async throws -> ListaDetails
    func setArchivedState(listaId _id: UUID, isArchived: Bool) async throws -> Void
    func setCompletedState(listaid _id: UUID, isCompleted: Bool) async throws -> Void
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
    
    func fetchListDetails(listaId _id: UUID) async throws -> ListaDetails {
        return try await datasource.getListaDetails(id: _id)
    }
    
    func setArchivedState(listaId _id: UUID, isArchived: Bool) async throws {
        return try await datasource.setArchivedState(id: _id, state: isArchived)
    }
    
    func setCompletedState(listaid _id: UUID, isCompleted: Bool) async throws -> Void {
        return try await datasource.setCompletedState(id: _id, state: isCompleted)
    }

}
