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

            Group {
                switch selectedTab.screen {
                case .cardsGroups:
                    ListOfGroupsScreenView(cardsManager: cardsManager)
                case .solveCards:
                    ListOfGroupsToSolve(cardsManager: cardsManager)
                case .profile:
                    ProfileScreen(cardsManager: cardsManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

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
