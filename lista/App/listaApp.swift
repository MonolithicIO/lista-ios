//
//  listaApp.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI
import CoreData

@main
struct listaApp: App {
    @State private var navigationCoordinator = NavigationCoordinator()
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationCoordinator.path) {
                HomeContentView()
                    .navigationDestination(for: Routes.self) { route in
                        destinationView(for: route)
                    }.environment(navigationCoordinator)
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
