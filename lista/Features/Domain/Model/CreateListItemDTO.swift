//
//  CreateListItemDTO.swift
//  lista
//
//  Created by Lucca Beurmann on 21/01/26.
//

import Foundation
import UIKit

struct CreateListItemDTO {
    let listId: UUID
    let title: String
    let description: String?
    let url: String?
    let image: UIImage?
}
