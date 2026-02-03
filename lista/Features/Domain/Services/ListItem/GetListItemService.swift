//
//  GetListItemService.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Foundation

protocol GetListItemServiceProtocol {
    func get(id: String) async throws -> ListaItem
}

final class GetListItemService: GetListItemServiceProtocol {
    private let repository: ListItemRepositoryProtocol

    init(repository: ListItemRepositoryProtocol) {
        self.repository = repository
    }

    func get(id: String) async throws -> ListaItem {
        guard let uuid = UUID.init(uuidString: id) else {
            throw NSError(
                domain: "GetListItemService",
                code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey: "Malformed item UUID: \(id)"
                ]
            )
        }
        
        return try await repository.getItem(itemId: uuid)
    }
}
