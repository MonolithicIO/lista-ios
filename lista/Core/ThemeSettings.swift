//
//  ThemeSettings.swift
//  lista
//
//  Manages app theme/appearance preferences
//

import Combine
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var id: String { rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
    
    var displayName: String {
        switch self {
        case .light:
            return String(localized: "theme.light")
        case .dark:
            return String(localized: "theme.dark")
        case .system:
            return String(localized: "theme.system")
        }
    }
    
    var icon: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "gear"
        }
    }
}

class ThemeSettings: ObservableObject {
    static let shared = ThemeSettings()
    
    private let userDefaultsKey = "app.selectedTheme"
    
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(
                currentTheme.rawValue,
                forKey: userDefaultsKey
            )
        }
    }
    
    private init() {
        // Load saved theme preference
        if let savedTheme = UserDefaults.standard.string(forKey: userDefaultsKey),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }
}
