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
}

extension Lista {
    func toUiModel() -> ListaUiModel {
        return ListaUiModel(id: self.id.uuidString, title: self.title)
    }
}
