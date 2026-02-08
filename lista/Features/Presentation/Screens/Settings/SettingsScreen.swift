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
            languageDisplayName: viewModel.languageDisplayName,
            selectedTheme: $viewModel.selectedTheme,
            availableThemes: viewModel.availableThemes,
            onThemeSelected: viewModel.updateTheme
        )
    }
}

struct SettingsContentView: View {
    @Binding var selectedLanguage: AppLanguage
    let availableLanguages: [AppLanguageUiModel]
    let languageDisplayName: String
    @Binding var selectedTheme: AppTheme
    let availableThemes: [AppTheme]
    let onThemeSelected: (AppTheme) -> Void

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
                
                NavigationLink {
                    ThemeSelectionView(
                        selectedTheme: $selectedTheme,
                        availableThemes: availableThemes,
                        onThemeSelected: onThemeSelected
                    )
                } label: {
                    HStack {
                        Text(String(localized: "settings.theme.title"))
                        Spacer()
                        Text(selectedTheme.displayName)
                            .foregroundStyle(AppColors.mutedForeground)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "settings.title"))
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct ThemeSelectionView: View {
    @Binding var selectedTheme: AppTheme
    let availableThemes: [AppTheme]
    let onThemeSelected: (AppTheme) -> Void
    
    var body: some View {
        List {
            Section {
                ForEach(availableThemes) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: selectedTheme == theme,
                        onTap: {
                            onThemeSelected(theme)
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "settings.theme.title"))
    }
}

struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: theme.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
                    .frame(width: 32, height: 32)
                
                Text(theme.displayName)
                    .font(.body)
                    .foregroundStyle(AppColors.cardForeground)
                
                Spacer()
                
                RadioButton(
                    isChecked: isSelected,
                    onToggle: onTap,
                    isEnabled: true
                )
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.card)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var iconColor: Color {
        switch theme {
        case .light:
            return AppColors.orange
        case .dark:
            return AppColors.purple
        case .system:
            return AppColors.blue
        }
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
            languageDisplayName: "English",
            selectedTheme: .constant(.system),
            availableThemes: AppTheme.allCases,
            onThemeSelected: { _ in }
        )
    }
}
