//
//  HomeState.swift
//  lista
//
//  Created by Lucca Beurmann on 05/02/26.
//

import Foundation
import SwiftUI

enum HomeFilter: String, CaseIterable, Identifiable {
    case active = "active"
    case completed = "completed"
    case archived = "archived"

    var id: String { rawValue }

    var displayName: LocalizedStringResource {
        switch self {
        case .active:
            return "filter.active"
        case .completed:
            return "filter.completed"
        case .archived:
            return "filter.archived"
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
