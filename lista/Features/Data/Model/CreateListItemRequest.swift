//
//  CreateItemRequest.swift
//  lista
//
//  Created by Lucca Beurmann on 12/05/26.
//

import Foundation

struct CreateListItemRequest {
    let listId: UUID
    let title: String
    let description: String?
    let url: String?
    let imagePath: String?
}
