//
//  ContentView.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cardsManager = CardsManager()
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedTab: TabItem = AppScreen.solveCards.tabItem
    @State private var refreshTrigger = false
    private var tabs: [TabItem] { AppScreen.allTabItems }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab.screen {
                case .cardsGroups, .solveCards, .profile:
                    themeManager.colors.background
                }
            }
            .ignoresSafeArea()
            .overlay(BackgroundLines())
            .id(refreshTrigger)

            Group {
                switch selectedTab.screen {
                case .cardsGroups:
                    ListOfGroupsScreenView(cardsManager: cardsManager)
                        .id(refreshTrigger)
                case .solveCards:
                    ListOfGroupsToSolve(cardsManager: cardsManager)
                        .id(refreshTrigger)
                case .profile:
                    ProfileScreen(cardsManager: cardsManager)
                        .id(refreshTrigger)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .themeAware()

            CustomTabBar(tabs: tabs, selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .environmentObject(themeManager)
        .environmentObject(languageManager)
        .onAppear {
            themeManager.applyNavigationBarAppearance()
        }
        .tint(themeManager.colors.accent)
    }
}

#Preview {
    ContentView()
}
