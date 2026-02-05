//
//  HomeState.swift
//  lista
//
//  Created by Lucca Beurmann on 05/02/26.
//

import Foundation

enum HomeFilter: String, CaseIterable, Identifiable {
    case active = "active"
    case completed = "completed"
    case archived = "archived"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .active:
            return String(localized: "filter.active")
        case .completed:
            return String(localized: "filter.completed")
        case .archived:
            return String(localized: "filter.archived")
        }
    }

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
