//
//  SettingsContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct SettingsScreen: View {
    @Environment(LanguageSettings.self) var languageSettings
    @Environment(ThemeSettings.self) var themeSettings

    var body: some View {
        @Bindable var language = languageSettings
        @Bindable var theme = themeSettings

        SettingsContentView(
            selectedLanguage: $language.currentLanguage,
            availableLanguages: language.availableLanguages,
            selectedTheme: $theme.currentTheme,
            availableThemes: theme.availableThemes,

        )
    }
}

struct SettingsContentView: View {
    @Binding var selectedLanguage: AppLanguage
    let availableLanguages: [AppLanguage]
    @Binding var selectedTheme: AppTheme
    let availableThemes: [AppTheme]
    @Environment(\.locale) var locale

    var body: some View {
        List {
            Section(
                header: Text("settings.section.preferences")
            ) {
                Picker(
                    "settings.language.title",
                    selection: $selectedLanguage
                ) {
                    ForEach(availableLanguages) { language in
                        Text(
                            locale.localizedString(
                                forLanguageCode: language.id
                            )!.capitalized
                        )
                        .tag(language)
                    }
                }
                .pickerStyle(.navigationLink)

                NavigationLink {
                    ThemeSelectionView(
                        selectedTheme: $selectedTheme,
                        availableThemes: availableThemes,
                    )
                } label: {
                    HStack {
                        Text("settings.theme.title")
                        Spacer()
                        Text(selectedTheme.displayNameKey)
                            .foregroundStyle(AppColors.mutedForeground)
                    }
                }
            }
        }
        .navigationTitle(LocalizedStringKey("settings.title"))
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        SettingsContentView(
            selectedLanguage: .constant(.english),
            availableLanguages: AppLanguage.allCases,
            selectedTheme: .constant(.system),
            availableThemes: AppTheme.allCases,
        )
    }
}
