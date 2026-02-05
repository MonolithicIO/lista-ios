//
//  ListUiModel.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Foundation

struct ListaUiModel: Identifiable {
    let id: String
    let title: String
    let itemCount: Int
    let completedCount: Int
    let status: ListaUiModelStatus
}

enum ListaUiModelStatus {
    case active
    case archived
    case completed
}

extension Lista {
    func toUiModel() -> ListaUiModel {
        return ListaUiModel(
            id: self.id.uuidString,
            title: self.title,
            itemCount: self.itemCount,
            completedCount: self.completedCount,
            status: self.toStatus()
        )
    }
    
    func toStatus() -> ListaUiModelStatus {
        if self.isArchived {
            return .archived
        } else if self.isCompleted {
            return .completed
        }
        
        return .active
    }
}
