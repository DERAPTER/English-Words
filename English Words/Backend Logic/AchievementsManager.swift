//
//  AchievementsManager.swift
//  English Words
//
//  Created by Егор Халиков on 10.04.2026.
//

import SwiftUI

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id = UUID()
    let titleKey: String
    let descriptionKey: String
    let icon: String
    let requiredValue: Int
    let type: AchievementType
    var isUnlocked: Bool = false
    var unlockedDate: Date? = nil
    
    var title: String {
        titleKey.localized()
    }
    
    var description: String {
        descriptionKey.localized()
    }
}

enum AchievementType: String, Codable {
    // Количество карточек
    case cardsCreated
    // Решённые карточки
    case cardsSolved
    // Серия (streak)
    case streak
    // Ежедневная цель
    case dailyGoalCompleted
    // Прогресс группы
    case groupPerfect
    case groupCompleted
    // Избранное
    case favourites
    // Группы
    case groupsCreated
}

// MARK: - Achievements Manager
class AchievementsManager: ObservableObject {
    static let shared = AchievementsManager()
    
    @Published var achievements: [Achievement] = []
    @Published var recentlyUnlocked: Achievement? = nil
    
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "achievements"
    
    private init() {
        loadAchievements()
    }
    
    // MARK: - All Achievements Definition
    private var allAchievements: [Achievement] {
        return [
            // 📚 Карточки - создано
            Achievement(titleKey: "achievement_cards_10", descriptionKey: "achievement_cards_10_desc", icon: "doc.fill", requiredValue: 10, type: .cardsCreated),
            Achievement(titleKey: "achievement_cards_50", descriptionKey: "achievement_cards_50_desc", icon: "doc.on.doc.fill", requiredValue: 50, type: .cardsCreated),
            Achievement(titleKey: "achievement_cards_100", descriptionKey: "achievement_cards_100_desc", icon: "books.vertical.fill", requiredValue: 100, type: .cardsCreated),
            Achievement(titleKey: "achievement_cards_250", descriptionKey: "achievement_cards_250_desc", icon: "globe", requiredValue: 250, type: .cardsCreated),
            Achievement(titleKey: "achievement_cards_500", descriptionKey: "achievement_cards_500_desc", icon: "book.fill", requiredValue: 500, type: .cardsCreated),
            Achievement(titleKey: "achievement_cards_1000", descriptionKey: "achievement_cards_1000_desc", icon: "character.book.closed.fill", requiredValue: 1000, type: .cardsCreated),
            
            // 🎯 Решённые карточки
            Achievement(titleKey: "achievement_solved_10", descriptionKey: "achievement_solved_10_desc", icon: "figure.walk", requiredValue: 10, type: .cardsSolved),
            Achievement(titleKey: "achievement_solved_50", descriptionKey: "achievement_solved_50_desc", icon: "graduationcap.fill", requiredValue: 50, type: .cardsSolved),
            Achievement(titleKey: "achievement_solved_100", descriptionKey: "achievement_solved_100_desc", icon: "star.fill", requiredValue: 100, type: .cardsSolved),
            Achievement(titleKey: "achievement_solved_250", descriptionKey: "achievement_solved_250_desc", icon: "crown.fill", requiredValue: 250, type: .cardsSolved),
            Achievement(titleKey: "achievement_solved_500", descriptionKey: "achievement_solved_500_desc", icon: "medal.fill", requiredValue: 500, type: .cardsSolved),
            Achievement(titleKey: "achievement_solved_1000", descriptionKey: "achievement_solved_1000_desc", icon: "person.crop.rectangle.stack.fill", requiredValue: 1000, type: .cardsSolved),
            
            // 🔥 Серия (streak)
            Achievement(titleKey: "achievement_streak_3", descriptionKey: "achievement_streak_3_desc", icon: "flame.fill", requiredValue: 3, type: .streak),
            Achievement(titleKey: "achievement_streak_7", descriptionKey: "achievement_streak_7_desc", icon: "clock.fill", requiredValue: 7, type: .streak),
            Achievement(titleKey: "achievement_streak_14", descriptionKey: "achievement_streak_14_desc", icon: "checkmark.seal.fill", requiredValue: 14, type: .streak),
            Achievement(titleKey: "achievement_streak_21", descriptionKey: "achievement_streak_21_desc", icon: "calendar.circle.fill", requiredValue: 21, type: .streak),
            Achievement(titleKey: "achievement_streak_30", descriptionKey: "achievement_streak_30_desc", icon: "bolt.fill", requiredValue: 30, type: .streak),
            Achievement(titleKey: "achievement_streak_50", descriptionKey: "achievement_streak_50_desc", icon: "hurricane", requiredValue: 50, type: .streak),
            Achievement(titleKey: "achievement_streak_100", descriptionKey: "achievement_streak_100_desc", icon: "crown.fill", requiredValue: 100, type: .streak),
            
            // ⭐ Ежедневная цель
            Achievement(titleKey: "achievement_goal_1", descriptionKey: "achievement_goal_1_desc", icon: "target", requiredValue: 1, type: .dailyGoalCompleted),
            Achievement(titleKey: "achievement_goal_5", descriptionKey: "achievement_goal_5_desc", icon: "5.circle.fill", requiredValue: 5, type: .dailyGoalCompleted),
            Achievement(titleKey: "achievement_goal_10", descriptionKey: "achievement_goal_10_desc", icon: "10.circle.fill", requiredValue: 10, type: .dailyGoalCompleted),
            Achievement(titleKey: "achievement_goal_25", descriptionKey: "achievement_goal_25_desc", icon: "calendar.badge.checkmark", requiredValue: 25, type: .dailyGoalCompleted),
            Achievement(titleKey: "achievement_goal_50", descriptionKey: "achievement_goal_50_desc", icon: "figure.run", requiredValue: 50, type: .dailyGoalCompleted),
            Achievement(titleKey: "achievement_goal_100", descriptionKey: "achievement_goal_100_desc", icon: "laurel.leading", requiredValue: 100, type: .dailyGoalCompleted),
            
            // ❤️ Избранное
            Achievement(titleKey: "achievement_fav_1", descriptionKey: "achievement_fav_1_desc", icon: "heart.fill", requiredValue: 1, type: .favourites),
            Achievement(titleKey: "achievement_fav_5", descriptionKey: "achievement_fav_5_desc", icon: "heart.circle.fill", requiredValue: 5, type: .favourites),
            Achievement(titleKey: "achievement_fav_10", descriptionKey: "achievement_fav_10_desc", icon: "heart.circle", requiredValue: 10, type: .favourites),
            Achievement(titleKey: "achievement_fav_25", descriptionKey: "achievement_fav_25_desc", icon: "star.square.fill", requiredValue: 25, type: .favourites),
            
            // 🎮 Группы
            Achievement(titleKey: "achievement_group_1", descriptionKey: "achievement_group_1_desc", icon: "folder.badge.plus", requiredValue: 1, type: .groupsCreated),
            Achievement(titleKey: "achievement_group_5", descriptionKey: "achievement_group_5_desc", icon: "folder.fill.badge.gearshape", requiredValue: 5, type: .groupsCreated),
            Achievement(titleKey: "achievement_group_10", descriptionKey: "achievement_group_10_desc", icon: "square.stack.3d.down.right.fill", requiredValue: 10, type: .groupsCreated),
        ]
    }
    
    // MARK: - Load/Save
    private func loadAchievements() {
        if let data = userDefaults.data(forKey: achievementsKey),
           let saved = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = saved
        } else {
            achievements = allAchievements
            saveAchievements()
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            userDefaults.set(data, forKey: achievementsKey)
        }
    }
    
    // MARK: - Check Achievements
    func checkAchievements(cardsManager: CardsManager) {
        var updated = false
        
        for i in 0..<achievements.count {
            if !achievements[i].isUnlocked {
                let isUnlocked = checkCondition(achievements[i], cardsManager: cardsManager)
                if isUnlocked {
                    achievements[i].isUnlocked = true
                    achievements[i].unlockedDate = Date()
                    updated = true
                    recentlyUnlocked = achievements[i]
                    
                    // Отправляем уведомление для показа анимации
                    NotificationCenter.default.post(name: .achievementUnlocked, object: achievements[i])
                    
                    // Скрываем уведомление через 3 секунды
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                        guard let self = self else { return }
                        if self.recentlyUnlocked?.id == achievements[i].id {
                            self.recentlyUnlocked = nil
                        }
                    }
                }
            }
        }
        
        if updated {
            saveAchievements()
        }
    }
    
    private func checkCondition(_ achievement: Achievement, cardsManager: CardsManager) -> Bool {
        switch achievement.type {
        case .cardsCreated:
            return cardsManager.totalCardsCount >= achievement.requiredValue
        case .cardsSolved:
            return cardsManager.totalSolved >= achievement.requiredValue
        case .streak:
            return cardsManager.streak >= achievement.requiredValue
        case .dailyGoalCompleted:
            return cardsManager.totalDaysGoalCompleted >= achievement.requiredValue
        case .groupPerfect:
            // TODO: реализовать подсчёт идеально пройденных групп
            return false
        case .groupCompleted:
            // TODO: реализовать подсчёт пройденных групп
            return false
        case .favourites:
            return cardsManager.favouritesCount >= achievement.requiredValue
        case .groupsCreated:
            return cardsManager.groups.filter { !cardsManager.isSystemGroup($0) }.count >= achievement.requiredValue
        }
    }
    
    // MARK: - Reset (для тестов)
    func resetAchievements() {
        achievements = allAchievements
        saveAchievements()
    }
}

// MARK: - Notification
extension Notification.Name {
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
}

// MARK: - Extension for CardsManager
extension CardsManager {
    var totalDaysGoalCompleted: Int {
        return activityHistory.filter { $0.value == true }.count
    }
}
