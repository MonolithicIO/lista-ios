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

    // MARK: - State properties
    @Published var selectedLanguage: AppLanguage {
        didSet {
            languageSettings.currentLanguage = selectedLanguage
            loadLanguages()
        }
    }
    @Published var appLanguages: [AppLanguageUiModel] = []
    var languageDisplayName: String {
        languageSettings.displayName(for: selectedLanguage)
    }

    // MARK: - Initializer
    init(languageSettings: LanguageSettings) {
        self.languageSettings = languageSettings
        self.selectedLanguage = languageSettings.currentLanguage
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
}
