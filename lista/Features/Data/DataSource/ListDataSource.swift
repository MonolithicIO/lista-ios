//
//  ListDataSource.swift
//  lista
//
//  Created by Lucca Beurmann on 15/01/26.
//

import CoreData
import Foundation

protocol ListDataSourceProtocol {
    func fetchLists(filter: FetchListFilter) async throws -> [Lista]
    func createList(title: String) async throws -> Lista
    func removeList(id: UUID) async throws
    func getListaDetails(id: UUID) async throws -> ListaDetails
    func setArchivedState(id: UUID, state: Bool) async throws
    func setCompletedState(id: UUID, state: Bool) async throws
}

final class ListDataSource: ListDataSourceProtocol {

    private let context: NSManagedObjectContext
    private let dateProvider: DateProviderProtocol

    init(
        context: NSManagedObjectContext,
        dateProvider: DateProviderProtocol,
    ) {
        self.context = context
        self.dateProvider = dateProvider
    }

    func setArchivedState(id: UUID, state: Bool) async throws {
        try await context.perform { [context] in

            let request: NSFetchRequest<ListaEntity> =
                ListaEntity.fetchRequest()

            request.fetchLimit = 1

            request.predicate = NSPredicate(
                format: "id == %@",
                id as CVarArg
            )

            guard let listaObject = try context.fetch(request).first else {
                throw NSError(
                    domain: "CoreData",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Lista não encontrada"
                    ]
                )
            }

            listaObject.isArchived = state
            listaObject.updatedAt = try self.dateProvider.currentDate()
        }
    }

    func fetchLists(filter: FetchListFilter) async throws -> [Lista] {
        try await context.perform { [context] in
            let request: NSFetchRequest<ListaEntity> =
                ListaEntity.fetchRequest()

            var predicates: [NSPredicate] = []

            switch filter.state {
            case .active:
                predicates.append(
                    NSPredicate(
                        format: "isCompleted == NO AND isArchived == NO"
                    )
                )

            case .completed:
                predicates.append(
                    NSPredicate(format: "isCompleted == YES")
                )

            case .archived:
                predicates.append(
                    NSPredicate(format: "isArchived == YES")
                )
            }

            if !filter.query.isEmpty {
                predicates.append(
                    NSPredicate(
                        format: "title CONTAINS[cd] %@",
                        filter.query
                    )
                )
            }

            request.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: predicates
            )

            request.sortDescriptors = [
                NSSortDescriptor(key: "title", ascending: true)
            ]

            let entities = try context.fetch(request)

            return entities.compactMap { entity in
                guard let id = entity.id,
                    let title = entity.title
                else {
                    return nil
                }

                // Get item counts from children relationship
                let tasksSet = entity.children as? Set<ListaItemEntity> ?? []
                let itemCount = tasksSet.count
                let completedCount = tasksSet.filter { $0.isCompleted }.count

                return Lista(
                    id: id,
                    title: title,
                    itemCount: itemCount,
                    completedCount: completedCount
                )
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
            entity.isArchived = false
            entity.isCompleted = false

            try context.save()

            guard let id = entity.id, let title = entity.title else {
                throw NSError(domain: "CoreData", code: 0)
            }

            return Lista(id: id, title: title, itemCount: 0, completedCount: 0)
        }
    }

    func removeList(id: UUID) async throws {
        try await context.perform { [context] in
            let request: NSFetchRequest<ListaEntity> =
                ListaEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            if let object = try context.fetch(request).first {
                context.delete(object)
                try context.save()
            }
        }
    }

    func getListaDetails(id: UUID) async throws -> ListaDetails {
        try await context.perform { [context] in
            let request: NSFetchRequest<ListaEntity> =
                ListaEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let object = try context.fetch(request).first else {
                throw NSError(
                    domain: "CoreData",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Lista não encontrada"
                    ]
                )
            }

            let tasksSet = object.children as? Set<ListaItemEntity> ?? []

            let itemsSorted = tasksSet.sorted {
                ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast)
            }

            let items: [ListaItem] = itemsSorted.compactMap { item in
                guard
                    let listId = object.id,
                    let itemId = item.id,
                    let title = item.title,
                    let createdAt = item.createdAt,
                    let updatedAt = item.updatedAt
                else { return nil }

                return ListaItem(
                    listId: listId,
                    id: itemId,
                    title: title,
                    description: item.note,
                    url: item.link,
                    updatedAt: updatedAt,
                    createdAt: createdAt,
                    isCompleted: item.isCompleted,
                    imageUrl: item.imageUrl
                )
            }

            guard
                let listId = object.id,
                let title = object.title,
                let createdAt = object.createdAt,
                let updatedAt = object.updatedAt
            else {
                throw NSError(domain: "CoreData", code: 0)
            }

            return ListaDetails(
                id: listId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                items: items,
                isArchived: object.isArchived,
                isCompleted: object.isCompleted
            )
        }
    }

    func setCompletedState(id: UUID, state: Bool) async throws {
        let now = try dateProvider.currentDate()

        try await context.perform { [context] in

            let request: NSFetchRequest<ListaEntity> =
                ListaEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.returnsObjectsAsFaults = false

            guard let list = try context.fetch(request).first else {
                throw NSError(
                    domain: "ListDataSource",
                    code: 404
                )
            }

            list.isCompleted = state
            list.updatedAt = now

            if state {
                if let children = list.children as? Set<ListaItemEntity> {
                    children.forEach { item in
                        item.updatedAt = now
                        item.isCompleted = state
                    }
                }
            }

            guard context.hasChanges else { return }

            try context.save()
        }
    }

}
