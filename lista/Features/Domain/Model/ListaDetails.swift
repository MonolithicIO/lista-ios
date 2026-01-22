//
//  ListaDetails.swift
//  lista
//
//  Created by Lucca Beurmann on 21/01/26.
//

import Foundation

struct ListaDetails {
    let id: UUID
    let title: String
    let createdAt: Date
    let updatedAt: Date
    let items: [ListaItem]
}
