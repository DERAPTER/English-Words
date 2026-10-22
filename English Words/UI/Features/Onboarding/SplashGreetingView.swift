//
//  SplashGreetingView.swift
//  English Words
//
//  Created by Егор Халиков on 23.10.2026.
//

import SwiftUI

struct SplashGreetingView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var isVisible = false
    
    // Определяем время суток
    private var greetingData: (text: String, icon: String, color: Color) {
        let hour = Calendar.current.component(.hour, from: Date())
        
        let nameText = userName.isEmpty ? "" : ", \(userName)"
        
        switch hour {
        case 5..<12:
            return ("greeting_morning".localized() + nameText, "sun.max.fill", .accent)
        case 12..<18:
            return ("greeting_day".localized() + nameText, "sun.max.circle.fill", .accent)
        case 18..<23:
            return ("greeting_evening".localized() + nameText, "sunset.fill", .accent)
        default:
            return ("greeting_night".localized() + nameText, "moon.stars.fill", .accent)
        }
    }
    
    var body: some View {
        ZStack {
            // Фон приложения
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                if hasCompletedOnboarding {
                    // Если пользователь уже знаком с приложением — здороваемся
                    Image(systemName: greetingData.icon)
                        .font(.system(size: 80))
                        .foregroundColor(greetingData.color)
                        .symbolEffect(.pulse, options: .repeating)
                    
                    Text(greetingData.text)
                        .font(.largeTitleCustom)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    // Если это первый запуск — просто красивый логотип
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accent)
                        .symbolEffect(.pulse, options: .repeating)
                }
            }
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isVisible = true
            }
            HapticService.shared.lightImpact()
        }
    }
}
