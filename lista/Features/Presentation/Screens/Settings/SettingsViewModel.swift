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
    private let languageSettings: LanguageSettingsProtocol

    // MARK: - State properties
    @State var selectedLanguage: AppLanguage
    @State var appLanguages: [AppLanguageUiModel] = []
    var languageDisplayName: String {
        languageSettings.displayName(for: selectedLanguage)
    }

    // MARK: - Initializer
    init(languageSettings: LanguageSettingsProtocol) {
        self.languageSettings = languageSettings
        self.selectedLanguage = languageSettings.currentLanguage
        loadLanguages()
    }

    // MARK: - Actions
    func updateLanguage(_ language: AppLanguageUiModel) {
        if language.id != selectedLanguage {
            languageSettings.setAppLanguage(language.id)
            selectedLanguage = language.id
            loadLanguages()
        }
    }

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
