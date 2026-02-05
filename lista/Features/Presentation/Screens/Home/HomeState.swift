//
//  HomeState.swift
//  lista
//
//  Created by Lucca Beurmann on 05/02/26.
//

import Foundation

enum HomeFilter: String, CaseIterable, Identifiable {
    case active = "Active"
    case completed = "Completed"
    case archived = "Archived"

    var id: String { rawValue }

    func toDomainModel() -> ListState {
        switch self {
        case .active:
            return .active
        case .completed:
            return .completed
        case .archived:
            return .archived
        }
    }
}
