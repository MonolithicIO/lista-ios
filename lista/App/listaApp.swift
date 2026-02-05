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
    @State private var languageSettings = LanguageSettings.shared

    var body: some Scene {
        WindowGroup {
            RootView(
                navigationCoordinator: navigationCoordinator,
                languageSettings: languageSettings
            )
        }
    }
}

struct RootView: View {
    @State var navigationCoordinator: NavigationCoordinator
    @State var languageSettings: LanguageSettings

    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            HomeScreen()
                .navigationDestination(for: Routes.self) { route in
                    destinationView(for: route)
                }
        }
        .environment(navigationCoordinator)
        .environment(\.locale, languageSettings.currentLanguage.locale)
    }

    @ViewBuilder
    private func destinationView(for route: Routes) -> some View {
        switch route {
        case .home:
            HomeScreen()

        case .details(let listaId, let listaTitle):
            DetailsScreen(
                listaId: listaId,
                listaTitle: listaTitle
            )

        case .settings:
            SettingsScreen()

        case .insertItem(listId: let listId, itemId: let itemId):
            InsertItemView(listId: listId, itemId: itemId)
        }
    }
}
