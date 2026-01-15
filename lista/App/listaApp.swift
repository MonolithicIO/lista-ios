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
    @State private var instanceKeeper = InstanceKeeper.shared

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationCoordinator.path) {
                HomeContentView()
                    .navigationDestination(for: Routes.self) { route in
                        destinationView(for: route)
                    }
                    .environment(navigationCoordinator)
                    .environment(instanceKeeper)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: Routes) -> some View {
        switch route {
        case .home:
            HomeContentView()

        case .details:
            DetailsContentView()

        case .setings:
            SettingsContentView()
        }
    }
}
