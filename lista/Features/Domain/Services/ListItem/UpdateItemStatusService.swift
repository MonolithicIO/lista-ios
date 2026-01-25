//
//  UpdateItemStatusService.swift
//  lista
//
//  Created by Lucca Beurmann on 25/01/26.
//

import Foundation

protocol UpdateItemStatusServiceProtocol {
    func updateItemStatus(itemId: String, isCompleted: Bool) async throws
}

final class UpdateItemStatusService: UpdateItemStatusServiceProtocol {
    private let repository: ListItemRepositoryProtocol

    init(repository: ListItemRepositoryProtocol) {
        self.repository = repository
    }

    func updateItemStatus(itemId: String, isCompleted: Bool) async throws {
        guard let itemUuid = UUID(uuidString: itemId) else {
            throw NSError(
                domain: "UpdateItemStatusService",
                code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Unable to parse UUID: \(itemId)"
                ]
            )
        }

        return try await repository.updateStatus(
            itemId: itemUuid,
            isActive: isCompleted
        )
    }
}
