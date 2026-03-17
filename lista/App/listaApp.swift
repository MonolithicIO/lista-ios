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
    @State private var themeSettings = ThemeSettings.shared

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .environment(navigationCoordinator)
        .environment(languageSettings)
        .environment(themeSettings)
    }
}

struct RootView: View {

    @Environment(NavigationCoordinator.self)
    var navigationCoordinator: NavigationCoordinator
    
    @Environment(LanguageSettings.self)
    var languageSettings
    
    @Environment(ThemeSettings.self)
    var themeSettings

    var body: some View {
        @Bindable var navigator = navigationCoordinator
        
        NavigationStack(path: $navigator.path) {
            HomeScreen()
                .navigationDestination(for: Routes.self) { route in
                    destinationView(for: route)
                }
        }
        .environment(
            \.locale,
            .init(
                identifier: languageSettings.currentLanguage.locale.identifier
            )
        )
        .preferredColorScheme(themeSettings.currentTheme.colorScheme)
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

        case .insertItem(let listId, let itemId):
            InsertItemView(listId: listId, itemId: itemId)
        }
    }
}
