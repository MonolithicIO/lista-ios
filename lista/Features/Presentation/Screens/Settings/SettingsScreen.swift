//
//  SettingsContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var languageSettings: LanguageSettings
    @EnvironmentObject var themeSettings: ThemeSettings

    var body: some View {
        SettingsContentView(
            selectedLanguage: $languageSettings.currentLanguage,
            availableLanguages: languageSettings.availableLanguages,
            selectedTheme: $themeSettings.currentTheme,
            availableThemes: themeSettings.availableThemes,

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
                header: Text(LocalizedStringKey("settings.section.preferences"))
            ) {
                Picker(
                    LocalizedStringKey("settings.language.title"),
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
                        Text(LocalizedStringKey("settings.theme.title"))
                        Spacer()
                        Text(LocalizedStringKey(selectedTheme.displayNameKey))
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
