//
//  CreateListItemDTO.swift
//  lista
//
//  Created by Lucca Beurmann on 21/01/26.
//

import Foundation

struct CreateListItemDTO {
    let listId: UUID
    let title: String
    let description: String?
    let url: String?
}
