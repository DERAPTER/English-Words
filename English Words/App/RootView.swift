//
//  RootView.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI

struct RootView: View {
    @Environment(AppContainer.self) private var container
    private let themeManager = ThemeManager.shared
    private let languageManager = LanguageManager.shared
    
    @State private var selectedTab: TabItem = TabItem(screen: .srsReview)
    @State private var refreshTrigger = false
    @State private var tabBarVisibility = TabBarVisibility()
    
    private var tabs: [TabItem] { TabItem.all }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            themeManager.colors.background
                .ignoresSafeArea()
                .overlay(BackgroundLines())
            
            Group {
                switch selectedTab.screen {
                case .cardsGroups:
                    GroupsListView(container: container)
                case .solveCards:
                    SolveListView(container: container)
                case .srsReview:
                    SRSOverviewView(container: container)
                case .profile:
                    ProfileView(container: container)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(refreshTrigger)
            
            if tabBarVisibility.isVisible {
                CustomTabBar(tabs: tabs, selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .environment(tabBarVisibility)
        .ignoresSafeArea(.container, edges: .bottom)
        .preferredColorScheme(themeManager.colorScheme)
        .tint(themeManager.colors.accent)
        .animation(.easeInOut(duration: 0.25), value: tabBarVisibility.isVisible)
        .onAppear {
            themeManager.applyNavigationBarAppearance()
        }
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            refreshTrigger.toggle()
        }
        .overlay(alignment: .top) {
            achievementBanner
        }
    }
    
    @ViewBuilder
    private var achievementBanner: some View {
        if let achievement = container.achievementsService.recentlyUnlocked {
            AchievementNotificationView(achievement: achievement)
                .transition(.move(edge: .top).combined(with: .opacity))
                .task(id: achievement.id) {
                    try? await Task.sleep(for: .seconds(3))
                    withAnimation {
                        container.achievementsService.consumeRecentlyUnlocked()
                    }
                }
                .zIndex(100)
        }
    }
}
