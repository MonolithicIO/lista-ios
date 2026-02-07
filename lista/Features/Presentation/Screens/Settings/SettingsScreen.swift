//
//  SettingsContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct SettingsScreen: View {
    @StateObject private var viewModel: SettingsViewModel

    init(
        viewModel: SettingsViewModel = InstanceKeeper.shared
            .provideSettingsViewModel()
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        SettingsContentView(
            selectedLanguage: $viewModel.selectedLanguage,
            availableLanguages: viewModel.appLanguages,
            languageDisplayName: viewModel.languageDisplayName
        )
    }
}

struct SettingsContentView: View {
    @Binding var selectedLanguage: AppLanguage
    let availableLanguages: [AppLanguageUiModel]
    let languageDisplayName: String

    var body: some View {
        List {
            Section(
                header: Text(String(localized: "settings.section.preferences"))
            ) {
                Picker(
                    String(localized: "settings.language.title"),
                    selection: $selectedLanguage
                ) {
                    ForEach(availableLanguages) { language in
                        Text(language.displayName)
                            .tag(language.id)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        }
        .navigationTitle(String(localized: "settings.title"))
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        SettingsContentView(
            selectedLanguage: .constant(.english),
            availableLanguages: [
                AppLanguageUiModel(displayName: "English", id: .english),
                AppLanguageUiModel(displayName: "Portuguese", id: .portuguese),
            ],
            languageDisplayName: "English"
        )
    }
}
