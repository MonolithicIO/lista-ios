//
//  FetchListaDetailsService.swift
//  lista
//
//  Created by Lucca Beurmann on 23/01/26.
//

import Foundation

protocol FetchListaDetailsServiceProtocol {
    func fetch (listaId _id: UUID) async throws -> ListaDetails
}

final class FetchListaDetailsService: FetchListaDetailsServiceProtocol {
    
    private let repository: ListRepositoryProtocol
    
    init(repository: ListRepositoryProtocol) {
        self.repository = repository
    }
    
    
    func fetch(listaId _id: UUID) async throws -> ListaDetails {
        return try await repository.fetchListDetails(listaId: _id)
    }
}
