//
//  ListItemDataSource.swift
//  lista
//
//  Created by Lucca Beurmann on 21/01/26.
//

import CoreData
import Foundation

protocol ListItemDataSourceProtocol {
    func createItem(item _dto: CreateListItemDTO) async throws -> ListaItem
    func updateStatus(itemId: UUID, isActive: Bool) async throws -> ListaItem
    func updateItem(item: UpdateListItemDTO) async throws -> ListaItem
    func deleteItem(itemId: UUID) async throws
    func getItem(itemId: UUID) async throws -> ListaItem
}

final class ListItemDataSource: ListItemDataSourceProtocol {

    private let context: NSManagedObjectContext
    private let dateProvider: DateProviderProtocol
    private let diskManager: DiskManagerProtocol
    private let uuidProvider: UUIDProviderProtocol

    init(
        context: NSManagedObjectContext,
        dateProvider: DateProviderProtocol,
        diskManager: DiskManagerProtocol,
        uuidProvider: UUIDProviderProtocol
    ) {
        self.context = context
        self.dateProvider = dateProvider
        self.diskManager = diskManager
        self.uuidProvider = uuidProvider
    }

    func createItem(item dto: CreateListItemDTO) async throws -> ListaItem {
        try await context.perform {

            var imageUrl: String?

            if let attachedImage = dto.image {
                imageUrl = try self.diskManager.saveImage(
                    image: attachedImage,
                    fileName: self.uuidProvider.provide().uuidString
                )
            }

            let listRequest: NSFetchRequest<ListaEntity> =
                ListaEntity.fetchRequest()
            listRequest.fetchLimit = 1
            listRequest.predicate = NSPredicate(
                format: "id == %@",
                dto.listId as CVarArg
            )

            guard let lista = try self.context.fetch(listRequest).first else {
                throw NSError(
                    domain: "ListItemDataSource",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "List with id \(dto.listId.uuidString) not found"
                    ]
                )
            }
            let listaItem = ListaItemEntity(context: self.context)
            listaItem.id = self.uuidProvider.provide()
            listaItem.title = dto.title
            listaItem.note = dto.description
            listaItem.link = dto.url
            listaItem.updatedAt = try self.dateProvider.currentDate()
            listaItem.createdAt = try self.dateProvider.currentDate()
            listaItem.lista = lista
            listaItem.isCompleted = false
            listaItem.imageUrl = imageUrl

            lista.updatedAt = try self.dateProvider.currentDate()

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

            let newDate = try self.dateProvider.currentDate()

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

    func updateItem(item dto: UpdateListItemDTO) async throws -> ListaItem {
        try await context.perform {
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

            // Handle image updates
            var newImageUrl: String? = listItem.imageUrl

            if dto.shouldRemoveImage {
                // Delete old image if exists
                if let oldImageUrl = listItem.imageUrl {
                    try? self.diskManager.deleteImage(fileName: oldImageUrl)
                }
                newImageUrl = nil
            } else if let newImage = dto.image {
                // Delete old image if exists
                if let oldImageUrl = listItem.imageUrl {
                    try? self.diskManager.deleteImage(fileName: oldImageUrl)
                }
                // Save new image
                newImageUrl = try self.diskManager.saveImage(
                    image: newImage,
                    fileName: self.uuidProvider.provide().uuidString
                )
            }

            // Update fields
            listItem.title = dto.title
            listItem.note = dto.description
            listItem.link = dto.url
            listItem.isCompleted = dto.isCompleted
            listItem.imageUrl = newImageUrl
            listItem.updatedAt = try self.dateProvider.currentDate()

            // Update parent list's updatedAt
            listItem.lista?.updatedAt = try self.dateProvider.currentDate()

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

            // Delete associated image if exists
            if let imageUrl = listItem.imageUrl {
                try? self.diskManager.deleteImage(fileName: imageUrl)
            }

            // Delete the item
            self.context.delete(listItem)

            // Update parent list's updatedAt
            listItem.lista?.updatedAt = try self.dateProvider.currentDate()

            if self.context.hasChanges {
                try self.context.save()
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
                    description: listItemEntity.description,
                    url: listItemEntity.link,
                    updatedAt: listItemEntity.updatedAt!,
                    createdAt: listItemEntity.createdAt!,
                    isCompleted: listItemEntity.isCompleted,
                    imageUrl: listItemEntity.imageUrl
                )
            }
        }
    }
}
