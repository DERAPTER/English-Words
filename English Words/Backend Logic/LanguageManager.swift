//
//  LanguageManager.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

// MARK: - Language Enum
enum AppLanguage: String, CaseIterable {
    case english = "en"
    case russian = "ru"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        }
    }
    
    var flagEmoji: String {
        switch self {
        case .english: return "🇬🇧"
        case .russian: return "🇷🇺"
        }
    }
}

// MARK: - Language Manager
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @AppStorage("appLanguage") private var languageRaw: String = AppLanguage.english.rawValue
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            languageRaw = currentLanguage.rawValue
            setLanguage(currentLanguage)
        }
    }
    
    // Кастомный bundle для локализации
    private var bundle: Bundle?
    
    private init() {
        let savedRaw = UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.english.rawValue
        let savedLanguage = AppLanguage(rawValue: savedRaw) ?? .english
        self.currentLanguage = savedLanguage
        self.bundle = LanguageManager.getBundle(for: savedLanguage)
        
        // Устанавливаем язык в UserDefaults
        UserDefaults.standard.set([savedLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func setLanguage(_ language: AppLanguage) {
        guard currentLanguage != language else { return }
        
        currentLanguage = language
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Обновляем кастомный bundle
        bundle = LanguageManager.getBundle(for: language)
        
        DispatchQueue.main.async {
            // Отправляем уведомление для обновления всех View
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        }
    }
    
    func localizedString(_ key: String) -> String {
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? NSLocalizedString(key, comment: "")
    }
    
    private static func getBundle(for language: AppLanguage) -> Bundle? {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj") else {
            return nil
        }
        return Bundle(path: path)
    }
}

// MARK: - String Extension с кастомной локализацией
extension String {
    func localized() -> String {
        return LanguageManager.shared.localizedString(self)
    }
}

// MARK: - View Modifier для автоматического обновления
struct LanguageAwareViewModifier: ViewModifier {
    @State private var refreshTrigger = false
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
                refreshTrigger.toggle()
            }
            .id(refreshTrigger)
    }
}

extension View {
    func languageAware() -> some View {
        modifier(LanguageAwareViewModifier())
    }
}
