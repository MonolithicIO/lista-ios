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
    func updateStatus(itemId: UUID, isActive: Bool) async throws
}

final class ListItemDataSource: ListItemDataSourceProtocol {
    private let context: NSManagedObjectContext
    private let dateProvider: DateProviderProtocol

    init(context: NSManagedObjectContext, dateProvider: DateProviderProtocol) {
        self.context = context
        self.dateProvider = dateProvider
    }

    func createItem(item _dto: CreateListItemDTO) async throws -> ListaItem {
        try await context.perform {
            let listRequest: NSFetchRequest<ListaEntity> =
                ListaEntity.fetchRequest()
            listRequest.fetchLimit = 1
            listRequest.predicate = NSPredicate(
                format: "id == %@",
                _dto.listId as CVarArg
            )

            guard let lista = try self.context.fetch(listRequest).first else {
                throw NSError(
                    domain: "ListItemDataSource",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "List with id \(_dto.listId.uuidString) not found"
                    ]
                )
            }
            let listaItem = ListaItemEntity(context: self.context)
            listaItem.id = UUID()
            listaItem.title = _dto.title
            listaItem.note = _dto.description
            listaItem.link = _dto.url
            listaItem.updatedAt = try self.dateProvider.currentDate()
            listaItem.createdAt = try self.dateProvider.currentDate()
            listaItem.lista = lista

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
                createdAt: listaItem.createdAt!
            )
        }
    }

    func updateStatus(itemId: UUID, isActive: Bool) async throws {
        try await context.perform {
            let listItemRequset = NSFetchRequest<ListaItemEntity>()
            listItemRequset.fetchLimit = 1
            listItemRequset.predicate = NSPredicate(
                format: "id ==%@",
                itemId as CVarArg
            )
            
            guard let listItem = try self.context.fetch(listItemRequset).first else {
                throw NSError(
                    domain: "ListItemDataSource",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "ListItem with id \(itemId.uuidString) not found"
                    ]
                )
            }
            
            listItem.isCompleted = isActive
            
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }
}
