//
//  listaApp.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import CoreData
import SwiftUI

@main
struct listaApp: App {
    @State private var navigationCoordinator = NavigationCoordinator()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationCoordinator.path) {
                HomeScreen()
                    .navigationDestination(for: Routes.self) { route in
                        destinationView(for: route)
                    }
                    .environment(navigationCoordinator)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: Routes) -> some View {
        switch route {
        case .home:
            HomeScreen()

        case .details:
            DetailsScreen()

        case .setings:
            SettingsScreen()
        }
    }
}
