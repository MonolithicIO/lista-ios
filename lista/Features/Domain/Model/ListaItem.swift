//
//  ListaItem.swift
//  lista
//
//  Created by Lucca Beurmann on 21/01/26.
//

import Foundation

struct ListaItem {
    let listId: UUID
    let id: UUID
    let title: String
    let description: String?
    let url: String?
    let updatedAt: Date
    let createdAt: Date
    let isCompleted: Bool
}
