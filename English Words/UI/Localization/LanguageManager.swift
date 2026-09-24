//
//  LanguageManager.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI

// Управляет языком приложения.

@Observable
final class LanguageManager {
    static let shared = LanguageManager()
    
    private static let storageKey = "appLanguage"
    
    var currentLanguage: AppLanguage {
        didSet {
            guard currentLanguage != oldValue else { return }
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Self.storageKey)
            UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            bundle = Self.loadBundle(for: currentLanguage)
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    
    private var bundle: Bundle?
    
    private init() {
        let raw = UserDefaults.standard.string(forKey: Self.storageKey) ?? AppLanguage.english.rawValue
        let lang = AppLanguage(rawValue: raw) ?? .english
        self.currentLanguage = lang
        self.bundle = Self.loadBundle(for: lang)
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }
    
    func localizedString(_ key: String) -> String {
        bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
    
    private static func loadBundle(for language: AppLanguage) -> Bundle? {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj") else {
            return nil
        }
        return Bundle(path: path)
    }
}

// MARK: - String Extension

extension String {
    func localized() -> String {
        LanguageManager.shared.localizedString(self)
    }
}
