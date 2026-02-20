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
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @StateObject private var languageSettings = LanguageSettings.shared
    @StateObject private var themeSettings = ThemeSettings.shared

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .environmentObject(navigationCoordinator)
        .environmentObject(languageSettings)
        .environmentObject(themeSettings)
    }
}

struct RootView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var languageSettings: LanguageSettings
    @EnvironmentObject var themeSettings: ThemeSettings

    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            HomeScreen()
                .navigationDestination(for: Routes.self) { route in
                    destinationView(for: route)
                }
        }
        .environmentObject(navigationCoordinator)
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
