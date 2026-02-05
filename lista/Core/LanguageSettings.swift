//
//  LanguageSettings.swift
//  lista
//
//  Manages app language preferences and provides locale configuration
//

import Combine
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case portuguese = "pt-BR"
    case spanish = "es"

    var id: String { rawValue }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

protocol LanguageSettingsProtocol {
    var currentLanguage: AppLanguage { get }
    func displayName(for language: AppLanguage) -> String
    func setAppLanguage(language: AppLanguage)
}

class LanguageSettings: LanguageSettingsProtocol {
    static let shared = LanguageSettings()

    private let userDefaultsKey = "app.selectedLanguage"

    var currentLanguage: AppLanguage

    private init() {
        // Check if user has manually selected a language
        if let savedLanguage = UserDefaults.standard.string(
            forKey: userDefaultsKey
        ),
            let language = AppLanguage(rawValue: savedLanguage)
        {
            self.currentLanguage = language
        } else {
            // Default to device language if supported, otherwise English
            self.currentLanguage = LanguageSettings.getDeviceLanguage()
        }
    }

    private static func getDeviceLanguage() -> AppLanguage {
        let preferredLanguages = Locale.preferredLanguages

        for languageCode in preferredLanguages {
            // Check for exact match first
            if let appLanguage = AppLanguage.allCases.first(where: {
                $0.rawValue == languageCode
            }) {
                return appLanguage
            }

            // Check for language prefix (e.g., "pt" matches "pt-BR", "es" matches "es-ES")
            let prefix = String(languageCode.prefix(2))
            if let appLanguage = AppLanguage.allCases.first(where: {
                $0.rawValue.hasPrefix(prefix)
            }) {
                return appLanguage
            }
        }

        // Default to English if no supported language found
        return .english
    }

    func displayName(for language: AppLanguage) -> String {
        // Return language name localized in the current app language
        let currentLocale = currentLanguage.locale
        return currentLocale.localizedString(forLanguageCode: language.rawValue)
            ?? language.rawValue
    }
    
    func setAppLanguage(language: AppLanguage) {
        UserDefaults.standard.set(
            language.rawValue,
            forKey: userDefaultsKey
        )
        currentLanguage = language
    }
}
