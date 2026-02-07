//
//  Routes.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI
import Combine

// MARK: - Routes & Destinations
enum Routes: Hashable {
    case home
    case details(listaId: String, listaTitle: String)
    case settings
    case insertItem(listId: String, itemId: String?)
}

// MARK: - Navigation Coordinator
class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()

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
