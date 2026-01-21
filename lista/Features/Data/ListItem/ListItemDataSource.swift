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
            let listRequest: NSFetchRequest<ListEntity> =
                ListEntity.fetchRequest()
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
            let listaItem = ListItemEntity(context: self.context)
            listaItem.title = _dto.title
            listaItem.note = _dto.description
            listaItem.link = _dto.url
            listaItem.updatedAt = try self.dateProvider.currentDate()
            listaItem.createdAt = try self.dateProvider.currentDate()
            listaItem.parent = lista

            if self.context.hasChanges {
                try self.context.save()
            }

            //            return ListaItem(
            //                listId: lista.id,
            //                id: listaItem.id,
            //                title: listaItem.title,
            //                description: listaItem.note,
            //                url: listaItem.link
            //            )
            return ListaItem(
                listId: UUID(),
                id: UUID(),
                title: "",
                description: listaItem.note,
                url: listaItem.link
            )
        }
    }
}
