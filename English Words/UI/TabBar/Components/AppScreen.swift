//
//  AppScreen.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation

enum AppScreen: CaseIterable {
    case cardsGroups
    case solveCards
    case profile
    
    var titleKey: String {
        switch self {
        case .cardsGroups: return "tab_cards"
        case .solveCards:  return "tab_solve"
        case .profile:     return "tab_profile"
        }
    }
    
    var iconName: String {
        switch self {
        case .cardsGroups: return "square.stack.3d.up.fill"
        case .solveCards:  return "play.circle.fill"
        case .profile:     return "person.crop.circle.fill"
        }
    }
    
    var title: String {
        titleKey.localized()
    }
}
