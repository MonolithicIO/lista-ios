//
//  ListItemDataSource.swift
//  lista
//
//  Created by Lucca Beurmann on 21/01/26.
//

import CoreData
import Foundation

protocol ListItemDataSourceProtocol {
    func createItem(item _dto: CreateListItemRequest) async throws -> ListaItem
    func updateStatus(itemId: UUID, isActive: Bool) async throws -> ListaItem
    func updateItem(item: UpdateListItemRequest) async throws -> ListaItem
    func deleteItem(itemId: UUID) async throws
    func getItem(itemId: UUID) async throws -> ListaItem
}

final class ListItemDataSource: ListItemDataSourceProtocol {

    private let context: NSManagedObjectContext
    private let dateProvider: DateProviderProtocol
    private let uuidProvider: UUIDProviderProtocol

    init(
        context: NSManagedObjectContext,
        dateProvider: DateProviderProtocol,
        diskManager: DiskManagerProtocol,
        uuidProvider: UUIDProviderProtocol
    ) {
        self.context = context
        self.dateProvider = dateProvider
        self.uuidProvider = uuidProvider
    }

    func createItem(item _request: CreateListItemRequest) async throws
        -> ListaItem
    {
        return try await context.perform {
            let listRequest: NSFetchRequest<ListaEntity> =
                ListaEntity.fetchRequest()
            listRequest.fetchLimit = 1
            listRequest.predicate = NSPredicate(
                format: "id == %@",
                _request.listId as CVarArg
            )

            guard let lista = try self.context.fetch(listRequest).first else {
                throw NSError(
                    domain: "ListItemDataSource",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "List with id \(_request.listId.uuidString) not found"
                    ]
                )
            }
            let listaItem = ListaItemEntity(context: self.context)
            listaItem.id = self.uuidProvider.provide()
            listaItem.title = _request.title
            listaItem.note = _request.description
            listaItem.link = _request.url
            listaItem.updatedAt = self.dateProvider.currentDate()
            listaItem.createdAt = self.dateProvider.currentDate()
            listaItem.imageUrl = _request.imagePath
            listaItem.isCompleted = false
            listaItem.lista = lista

            lista.updatedAt = self.dateProvider.currentDate()

            if self.context.hasChanges {
                try self.context.save()
            }

            return ListaItem(
                listId: lista.id!,
                id: listaItem.id!,
                title: listaItem.title!,
                description: listaItem.note,
                url: listaItem.link,
                updatedAt: listaItem.updatedAt!,
                createdAt: listaItem.createdAt!,
                isCompleted: listaItem.isCompleted,
                imageUrl: listaItem.imageUrl
            )
        }
    }

    func updateStatus(itemId: UUID, isActive: Bool) async throws -> ListaItem {
        try await context.perform {
            let listItemRequset = ListaItemEntity.fetchRequest()
            listItemRequset.fetchLimit = 1
            listItemRequset.predicate = NSPredicate(
                format: "id ==%@",
                itemId as CVarArg
            )

            guard let listItem = try self.context.fetch(listItemRequset).first
            else {
                throw NSError(
                    domain: "ListItemDataSource",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "ListItem with id \(itemId.uuidString) not found"
                    ]
                )
            }

            let newDate = self.dateProvider.currentDate()

            listItem.isCompleted = isActive
            listItem.updatedAt = newDate
            listItem.lista?.updatedAt = newDate

            if self.context.hasChanges {
                try self.context.save()
            }

            return ListaItem(
                listId: listItem.lista?.id ?? UUID(),
                id: listItem.id!,
                title: listItem.title!,
                description: listItem.note,
                url: listItem.link,
                updatedAt: listItem.updatedAt!,
                createdAt: listItem.createdAt!,
                isCompleted: listItem.isCompleted,
                imageUrl: listItem.imageUrl
            )
        }
    }

    func updateItem(item dto: UpdateListItemRequest) async throws -> ListaItem {
        return try await context.perform {
            let itemRequest = ListaItemEntity.fetchRequest()
            itemRequest.fetchLimit = 1
            itemRequest.predicate = NSPredicate(
                format: "id == %@",
                dto.itemId as CVarArg
            )

            guard let listItem = try self.context.fetch(itemRequest).first
            else {
                throw NSError(
                    domain: "ListItemDataSource",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "ListItem with id \(dto.itemId.uuidString) not found"
                    ]
                )
            }

            listItem.title = dto.title
            listItem.note = dto.description
            listItem.link = dto.url
            listItem.isCompleted = dto.isCompleted
            listItem.imageUrl = dto.itemImagePath
            listItem.updatedAt = self.dateProvider.currentDate()
            listItem.lista?.updatedAt = self.dateProvider.currentDate()

            if self.context.hasChanges {
                try self.context.save()
            }

            return ListaItem(
                listId: listItem.lista?.id ?? UUID(),
                id: listItem.id!,
                title: listItem.title!,
                description: listItem.note,
                url: listItem.link,
                updatedAt: listItem.updatedAt!,
                createdAt: listItem.createdAt!,
                isCompleted: listItem.isCompleted,
                imageUrl: listItem.imageUrl
            )
        }
    }

    func deleteItem(itemId: UUID) async throws {
        try await context.perform {
            let itemRequest = ListaItemEntity.fetchRequest()
            itemRequest.fetchLimit = 1
            itemRequest.predicate = NSPredicate(
                format: "id == %@",
                itemId as CVarArg
            )

            guard let listItem = try self.context.fetch(itemRequest).first
            else {
                throw NSError(
                    domain: "ListItemDataSource",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "ListItem with id \(itemId.uuidString) not found"
                    ]
                )
            }

            self.context.delete(listItem)

            listItem.lista?.updatedAt = self.dateProvider.currentDate()

            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    func getItem(itemId: UUID) async throws -> ListaItem {
        try await context.perform {
            let itemRequest = ListaItemEntity.fetchRequest()
            itemRequest.fetchLimit = 1
            itemRequest.predicate = NSPredicate(
                format: "id ==%@",
                itemId as CVarArg
            )

            guard
                let listItemEntity = try self.context.fetch(itemRequest)
                    .first
            else {
                throw NSError(
                    domain: "ListItemDataSource",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "ListItem with id \(itemId.uuidString) not found"
                    ]
                )
            }

            return ListaItem(
                listId: listItemEntity.lista!.id!,
                id: listItemEntity.id!,
                title: listItemEntity.title!,
                description: listItemEntity.note,
                url: listItemEntity.link,
                updatedAt: listItemEntity.updatedAt!,
                createdAt: listItemEntity.createdAt!,
                isCompleted: listItemEntity.isCompleted,
                imageUrl: listItemEntity.imageUrl
            )
        }
    }
}
