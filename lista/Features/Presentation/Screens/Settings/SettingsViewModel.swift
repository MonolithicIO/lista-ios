//
//  SettingsViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 05/02/26.
//

import Combine
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {

    // MARK: - Input properties
    private let languageSettings: LanguageSettings
    private let themeSettings: ThemeSettings

    // MARK: - State properties
    @Published var selectedLanguage: AppLanguage {
        didSet {
            languageSettings.currentLanguage = selectedLanguage
            loadLanguages()
        }
    }
    @Published var selectedTheme: AppTheme {
        didSet {
            themeSettings.currentTheme = selectedTheme
        }
    }
    @Published var appLanguages: [AppLanguageUiModel] = []
    var languageDisplayName: String {
        languageSettings.displayName(for: selectedLanguage)
    }
    var availableThemes: [AppTheme] {
        AppTheme.allCases
    }

    // MARK: - Initializer
    init(
        languageSettings: LanguageSettings,
        themeSettings: ThemeSettings
    ) {
        self.languageSettings = languageSettings
        self.themeSettings = themeSettings
        self.selectedLanguage = languageSettings.currentLanguage
        self.selectedTheme = themeSettings.currentTheme
        loadLanguages()
    }

    // MARK: - Actions
    func loadLanguages() {
        let languages = AppLanguage.allCases.map({ language in
            AppLanguageUiModel(
                displayName: languageSettings.displayName(for: language),
                id: language
            )
        })
        appLanguages = languages
    }
    
    func updateTheme(_ theme: AppTheme) {
        selectedTheme = theme
    }
}
