//
//  Card.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation
import SwiftData

/// Карточка — основная сущность приложения.
/// Один экземпляр Card может принадлежать нескольким CardGroup через relationship.
@Model
final class Card {
    @Attribute(.unique) var id: UUID
    var originWord: String
    var translatedWord: String
    var isFavourite: Bool
    var dateAdded: Date
    var correctCount: Int
    var wrongCount: Int
    
    /// Связь many-to-many с группами.
    /// inverse задаётся на стороне CardGroup.
    @Relationship(inverse: \CardGroup.cards)
    var groups: [CardGroup] = []
    
    init(
        origin: String,
        translated: String,
        dateAdded: Date = .now
    ) {
        self.id = UUID()
        self.originWord = origin
        self.translatedWord = translated
        self.isFavourite = false
        self.dateAdded = dateAdded
        self.correctCount = 0
        self.wrongCount = 0
    }
    
    // MARK: - Computed
    
    var totalAttempts: Int {
        correctCount + wrongCount
    }
    
    var successRate: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctCount) / Double(totalAttempts)
    }
}
