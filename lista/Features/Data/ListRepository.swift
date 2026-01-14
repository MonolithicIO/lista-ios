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

    private var lists: [List] = []

    func fetchLists() async -> [List] {
        return lists
    }

    func createList(title: String) async -> List {
        let newItem = List(id: UUID.init(), title: title)
        lists.append(newItem)
        return newItem
    }

    func removeList(id: UUID) async {
        lists = lists.filter { $0.id != id }
    }

}
