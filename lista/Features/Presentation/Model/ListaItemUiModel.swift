//
//  ListaItemUiModel.swift
//  lista
//
//  Created by Lucca Beurmann on 21/01/26.
//

import Foundation

struct ListaItemUiModel: Identifiable {
    let listId: String
    let id: String
    let title: String
    let description: String?
    let url: String?
    let isCompleted: Bool
}

extension ListaItem {
    func toUiModel() -> ListaItemUiModel {
        return ListaItemUiModel(
            listId: self.listId.uuidString,
            id: self.id.uuidString,
            title: self.title,
            description: self.description,
            url: self.url,
            isCompleted: self.isCompleted
        )
    }
}
