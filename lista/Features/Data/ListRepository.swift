//
//  ListRepository.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Foundation

protocol ListRepositoryProtocol {

    func fetchLists() async -> [List]
    func createList(title: String) async -> List
    func removeList(id: UUID) async

}

final class ListRepository: ListRepositoryProtocol {
    
    private let datasource: ListDataSourceProtocol
    
    init(datasource: ListDataSourceProtocol) {
        self.datasource = datasource
    }

    func fetchLists() async -> [List] {
        return await datasource.fetchLists()
    }

    func createList(title: String) async -> List {
        return await datasource.createList(title: title)
    }

    func removeList(id: UUID) async {
        await datasource.removeList(id: id)
    }

}
