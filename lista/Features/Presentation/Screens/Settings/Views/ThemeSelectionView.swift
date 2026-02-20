//
//  ThemeSelectionView.swift
//  lista
//
//  Created by Lucca Beurmann on 20/02/26.
//

import Foundation
import SwiftUI

struct ThemeSelectionView: View {
    @Binding var selectedTheme: AppTheme
    let availableThemes: [AppTheme]

    var body: some View {
        List {
            Section {
                ForEach(availableThemes) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: selectedTheme == theme,
                        onTap: {
                            selectedTheme = theme
                        }
                    )
                    .listRowInsets(
                        EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(LocalizedStringKey("settings.theme.title"))
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

                Text(theme.displayNameKey)
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
