//
//  UserSettings.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation
import SwiftData

/// Singleton-модель для настроек и общей статистики.
/// Всегда один экземпляр с `id == "singleton"`.
@Model
final class UserSettings {
    @Attribute(.unique) var id: String
    
    // Ежедневная цель
    var dailyGoal: Int
    
    // Серия и общая статистика
    var streak: Int
    var totalSolved: Int
    var lastActiveDate: Date
    var dailyGoalRewarded: Bool
    
    // Достижения
    var unlockedAchievementIDs: [String]
    var achievementUnlockDates: [String: Date]
    
    init() {
        self.id = "singleton"
        self.dailyGoal = 20
        self.streak = 0
        self.totalSolved = 0
        self.lastActiveDate = .now
        self.dailyGoalRewarded = false
        self.unlockedAchievementIDs = []
        self.achievementUnlockDates = [:]
    }
    
    // MARK: - Achievement helpers
    
    func isUnlocked(_ achievementID: String) -> Bool {
        unlockedAchievementIDs.contains(achievementID)
    }
    
    func unlock(_ achievementID: String, on date: Date = .now) {
        guard !unlockedAchievementIDs.contains(achievementID) else { return }
        unlockedAchievementIDs.append(achievementID)
        achievementUnlockDates[achievementID] = date
    }
}
