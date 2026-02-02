//
//  UpdateListItemDTO.swift
//  lista
//

import Foundation
import UIKit

struct UpdateListItemDTO {
    let itemId: UUID
    let title: String
    let description: String?
    let url: String?
    let isCompleted: Bool
    let image: UIImage?
    let shouldRemoveImage: Bool
}
