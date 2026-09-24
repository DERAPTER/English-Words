//
//  RootView.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI

/// Корневой экран приложения. Содержит таббар и переключает вкладки.
/// Здесь же будут глобальные оверлеи (уведомления о достижениях).
struct RootView: View {
    @Environment(AppContainer.self) private var container
    private let themeManager = ThemeManager.shared
    private let languageManager = LanguageManager.shared
    
    @State private var selectedTab: TabItem = TabItem(screen: .cardsGroups)
    @State private var refreshTrigger = false
    
    private var tabs: [TabItem] { TabItem.all }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Фон под всей областью приложения
            themeManager.colors.background
                .ignoresSafeArea()
            //TODO: REMOVE BackgroundLines
                .overlay(BackgroundLines())
            
            // Активный экран
            Group {
                switch selectedTab.screen {
                case .cardsGroups:
                    placeholder(for: .cardsGroups)
                case .solveCards:
                    placeholder(for: .solveCards)
                case .profile:
                    placeholder(for: .profile)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(refreshTrigger)
            
            // Таббар
            CustomTabBar(tabs: tabs, selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .preferredColorScheme(themeManager.colorScheme)
        .tint(themeManager.colors.accent)
        .onAppear {
            themeManager.applyNavigationBarAppearance()
        }
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            refreshTrigger.toggle()
        }
    }
    
    // Заглушки для экранов — заменятся по мере переноса фич
    @ViewBuilder
    private func placeholder(for screen: AppScreen) -> some View {
        VStack(spacing: 16) {
            Image(systemName: screen.iconName)
                .font(.system(size: 60))
                .foregroundColor(.accent)
            Text(screen.title)
                .font(.largeTitleCustom)
                .foregroundColor(.textPrimary)
            Text("В разработке")
                .font(.bodyCustom)
                .foregroundColor(.textSecondary)
        }
    }
}
