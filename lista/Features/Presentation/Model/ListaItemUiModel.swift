//
//  ListaItemUiModel.swift
//  lista
//
//  Created by Lucca Beurmann on 21/01/26.
//

import Foundation

struct ListaItemUiModel: Identifiable {
    let listId: String
    let id: UUID
    let title: String
    let description: String?
    let url: String?
}
