//
//  DesignSystem.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

// MARK: - Dynamic Colors (через Environment или ThemeManager)
// Для удобства использования в коде без постоянного доступа к ThemeManager
// Рекомендуется использовать ThemeManager.shared.colors.XXX

// MARK: - Фоновые линии (остаются без изменений)
struct BackgroundLines: View {
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 100))
                path.addLine(to: CGPoint(x: 200, y: 300))
            }
            .stroke(Color.brown.opacity(0.08), lineWidth: 2)
            
            Circle()
                .fill(Color.brown.opacity(0.03))
                .frame(width: 300, height: 300)
                .offset(x: 200, y: -50)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

extension Color {
    static var appBackground: Color {
        ThemeManager.shared.colors.background
    }
    
    static var cardBackground: Color {
        ThemeManager.shared.colors.cardBackground
    }
    
    static var textPrimary: Color {
        ThemeManager.shared.colors.textPrimary
    }
    
    static var textSecondary: Color {
        ThemeManager.shared.colors.textSecondary
    }
    
    static var accent: Color {
        ThemeManager.shared.colors.accent
    }
    
    static var stroke: Color {
        ThemeManager.shared.colors.stroke
    }
    
    static var shadowColor: Color {
        ThemeManager.shared.colors.shadowColor
    }
    
    static var correct: Color {
        ThemeManager.shared.colors.correct
    }
    
    static var wrong: Color {
        ThemeManager.shared.colors.wrong
    }
}

// MARK: - Navigation Bar Customization
extension UINavigationBar {
    static func customizeAppearance(with colors: ThemeColors) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(colors.background)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(colors.textPrimary)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(colors.textPrimary)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(colors.accent)
    }
}

// MARK: - Расширения шрифтов (без изменений)
extension Font {
    static let largeTitleCustom = Font.largeTitle.weight(.bold)
    static let titleCustom = Font.title2.weight(.semibold)
    static let bodyCustom = Font.body
    static let captionCustom = Font.caption.weight(.medium)
}
