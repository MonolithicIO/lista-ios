//
//  UpdateListItemRequest.swift
//  lista
//
//  Created by Lucca Beurmann on 12/05/26.
//
import Foundation

struct UpdateListItemRequest {
    let itemId: UUID
    let title: String
    let description: String?
    let url: String?
    let isCompleted: Bool
    let itemImagePath: String?
}
