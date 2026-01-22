//
//  ListDataSource.swift
//  lista
//
//  Created by Lucca Beurmann on 15/01/26.
//

import CoreData
import Foundation

protocol ListDataSourceProtocol {
    func fetchLists() async throws -> [Lista]
    func createList(title: String) async throws -> Lista
    func removeList(id: UUID) async throws
    func getListaDetails(id: UUID) async throws -> ListaDetails
}

final class ListDataSource: ListDataSourceProtocol {

    private let context: NSManagedObjectContext
    private let dateProvider: DateProviderProtocol

    init(context: NSManagedObjectContext, dateProvider: DateProviderProtocol) {
        self.context = context
        self.dateProvider = dateProvider
    }

    func fetchLists() async throws -> [Lista] {
        try await context.perform { [context] in
            let request: NSFetchRequest<ListaEntity> = ListaEntity.fetchRequest()
            let entities: [ListaEntity] = try context.fetch(request)

            return entities.compactMap { entity -> Lista? in
                return Lista(id: entity.id!, title: entity.title!)
            }
        }
    }

    func createList(title: String) async throws -> Lista {
        try await context.perform { [context] in
            let entity = ListaEntity(context: context)
            entity.id = UUID()
            entity.title = title
            entity.createdAt = try self.dateProvider.currentDate()
            entity.updatedAt = try self.dateProvider.currentDate()

            try context.save()

            guard let id = entity.id, let title = entity.title else {
                throw NSError(domain: "CoreData", code: 0)
            }

            return Lista(id: id, title: title)
        }
    }

    func removeList(id: UUID) async throws {
        try await context.perform { [context] in
            let request: NSFetchRequest<ListaEntity> = ListaEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            if let object = try context.fetch(request).first {
                context.delete(object)
                try context.save()
            }
        }
    }

    func getListaDetails(id: UUID) async throws -> ListaDetails {
        try await context.perform {
            let request: NSFetchRequest<ListaEntity> = ListaEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            let object = try self.context.fetch(request).first!

            return ListaDetails(
                id: object.id!,
                title: object.title!,
                createdAt: object.createdAt!,
                updatedAt: object.updatedAt!,
                items: []
            )
        }
    }
}
