//
//  TabItem.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct TabItem: Hashable {
    let titleKey: String
    let icon: String
    let screen: AppScreen
    
    var localizedTitle: String {
        titleKey.localized()
    }

    static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        lhs.screen == rhs.screen
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(screen)
    }
}

enum AppScreen: CaseIterable {
    case cardsGroups
    case solveCards
    case profile
    
    var tabItem: TabItem {
        switch self {
        case .cardsGroups:
            return TabItem(titleKey: "tab_cards", icon: "folder", screen: self)
        case .solveCards:
            return TabItem(titleKey: "tab_solve", icon: "graduationcap", screen: self)
        case .profile:
            return TabItem(titleKey: "tab_profile", icon: "person", screen: self)
        }
    }
    
    static var allTabItems: [TabItem] {
        return AppScreen.allCases.map { $0.tabItem }
    }
}
