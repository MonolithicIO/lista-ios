//
//  Routes.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

// MARK: - Routes & Destinations
enum Routes: Hashable {
    case home
    case details
    case setings
}

// MARK: - Navigation Coordinator
@Observable
class NavigationCoordinator {
    var path = NavigationPath()

    func push(_ route: Routes) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
