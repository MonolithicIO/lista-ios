//
//  ListUiModel.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Foundation

struct ListUiModel: Identifiable {
    let id: String
    let title: String
}

extension Lista {
    func toUiModel() -> ListUiModel {
        return ListUiModel(id: self.id.uuidString, title: self.title)
    }
}
