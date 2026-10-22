//
//  OnboardingView.swift
//  English Words
//
//  Created by Егор Халиков on 22.10.2026.
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "book.closed.fill",
            title: "onboarding_1_title".localized(),
            description: "onboarding_1_desc".localized(),
            color: .blue
        ),
        OnboardingPage(
            icon: "rectangle.stack.fill",
            title: "onboarding_2_title".localized(),
            description: "onboarding_2_desc".localized(),
            color: .green
        ),
        OnboardingPage(
            icon: "clock.arrow.circlepath",
            title: "onboarding_3_title".localized(),
            description: "onboarding_3_desc".localized(),
            color: .orange
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "onboarding_4_title".localized(),
            description: "onboarding_4_desc".localized(),
            color: .purple
        )
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Кнопка пропуска (сверху справа)
                HStack {
                    Spacer()
                    Button {
                        finishOnboarding()
                    } label: {
                        Text("onboarding_skip".localized())
                            .font(.bodyCustom)
                            .foregroundColor(.textSecondary)
                    }
                    .padding()
                    .opacity(currentPage == pages.count - 1 ? 0 : 1)
                }
                
                // Свайпающиеся страницы
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageView(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Нижняя панель (Индикаторы + Кнопка)
                VStack(spacing: 24) {
                    // Точки-индикаторы
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.accent : Color.stroke)
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    // Главная кнопка
                    Button {
                        if currentPage == pages.count - 1 {
                            onFinish()
                        } else {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    } label: {
                        Text(currentPage == pages.count - 1 ? "onboarding_start".localized() : "onboarding_next".localized())
                            .font(.bodyCustom.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accent)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Page View
    
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 200, height: 200)
                
                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundColor(page.color)
            }
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitleCustom)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(page.description)
                    .font(.bodyCustom)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    private func finishOnboarding() {
        onFinish()
    }
}

// MARK: - Model

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}
