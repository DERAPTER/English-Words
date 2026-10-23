//
//  BackupService.swift
//  English Words
//
//  Created by Егор Халиков on 23.10.2026.
//

import Foundation
import SwiftData

@MainActor
enum BackupService {
    
    // MARK: - Export
    
    static func createBackup(context: ModelContext) throws -> Data {
        let cards = try context.fetch(FetchDescriptor<Card>())
        let groups = try context.fetch(FetchDescriptor<CardGroup>())
        let stats = try context.fetch(FetchDescriptor<DailyStat>())
        
        // Настройки (singleton)
        let settingsPredicate = #Predicate<UserSettings> { $0.id == "singleton" }
        let settingsArray = try context.fetch(FetchDescriptor<UserSettings>(predicate: settingsPredicate))
        guard let settings = settingsArray.first else {
            throw NSError(domain: "Backup", code: 1, userInfo: [NSLocalizedDescriptionKey: "Settings not found"])
        }
        
        // Маппинг SwiftData -> DTO
        let backupCards = cards.map { card in
            BackupCard(
                id: card.id,
                originWord: card.originWord,
                translatedWord: card.translatedWord,
                originDescription: card.originDescription,
                translatedDescription: card.translatedDescription,
                isFavourite: card.isFavourite,
                dateAdded: card.dateAdded,
                correctCount: card.correctCount,
                wrongCount: card.wrongCount,
                easeFactor: card.easeFactor,
                intervalDays: card.intervalDays,
                repetitions: card.repetitions,
                nextReviewDate: card.nextReviewDate,
                lastReviewDate: card.lastReviewDate,
                groupIDs: card.groups.map(\.id)
            )
        }
        
        let backupGroups = groups.map { group in
            BackupGroup(
                id: group.id,
                name: group.name,
                createdAt: group.createdAt,
                orderIndex: group.orderIndex
            )
        }
        
        let backupStats = stats.map { stat in
            BackupDailyStat(
                dateKey: stat.dateKey,
                date: stat.date,
                solvedCount: stat.solvedCount,
                goalCompleted: stat.goalCompleted,
                srsCleared: stat.srsCleared
            )
        }
        
        let backupSettings = BackupUserSettings(
            dailyGoal: settings.dailyGoal,
            streak: settings.streak,
            totalSolved: settings.totalSolved,
            lastActiveDate: settings.lastActiveDate,
            dailyGoalRewarded: settings.dailyGoalRewarded,
            srsStreak: settings.srsStreak,
            unlockedAchievementIDs: settings.unlockedAchievementIDs,
            achievementUnlockDates: settings.achievementUnlockDates
        )
        
        let root = BackupRoot(
            version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            exportDate: .now,
            cards: backupCards,
            groups: backupGroups,
            stats: backupStats,
            settings: backupSettings
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(root)
    }
    
    // MARK: - Import (Restore)
    
    static func restoreBackup(from data: Data, context: ModelContext) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backup = try decoder.decode(BackupRoot.self, from: data)
        
        // 1. Очищаем текущую базу
        try context.delete(model: Card.self)
        try context.delete(model: CardGroup.self)
        try context.delete(model: DailyStat.self)
        try context.delete(model: UserSettings.self)
        try context.save() // Фиксируем очистку
        
        // 2. Восстанавливаем группы
        var groupMap: [UUID: CardGroup] = [:]
        for g in backup.groups {
            let group = CardGroup(name: g.name, orderIndex: g.orderIndex)
            group.id = g.id
            group.createdAt = g.createdAt
            context.insert(group)
            groupMap[g.id] = group
        }
        
        // 3. Восстанавливаем карточки
        for c in backup.cards {
            let card = Card(origin: c.originWord, translated: c.translatedWord, dateAdded: c.dateAdded)
            card.id = c.id
            card.originDescription = c.originDescription
            card.translatedDescription = c.translatedDescription
            card.isFavourite = c.isFavourite
            card.correctCount = c.correctCount
            card.wrongCount = c.wrongCount
            card.easeFactor = c.easeFactor
            card.intervalDays = c.intervalDays
            card.repetitions = c.repetitions
            card.nextReviewDate = c.nextReviewDate
            card.lastReviewDate = c.lastReviewDate
            
            // Восстанавливаем связи
            card.groups = c.groupIDs.compactMap { groupMap[$0] }
            
            context.insert(card)
        }
        
        // 4. Восстанавливаем статистику
        for s in backup.stats {
            let stat = DailyStat(date: s.date, solvedCount: s.solvedCount, goalCompleted: s.goalCompleted, srsCleared: s.srsCleared)
            stat.dateKey = s.dateKey
            context.insert(stat)
        }
        
        // 5. Восстанавливаем настройки
        let newSettings = UserSettings()
        newSettings.dailyGoal = backup.settings.dailyGoal
        newSettings.streak = backup.settings.streak
        newSettings.totalSolved = backup.settings.totalSolved
        newSettings.lastActiveDate = backup.settings.lastActiveDate
        newSettings.dailyGoalRewarded = backup.settings.dailyGoalRewarded
        newSettings.srsStreak = backup.settings.srsStreak
        newSettings.unlockedAchievementIDs = backup.settings.unlockedAchievementIDs
        newSettings.achievementUnlockDates = backup.settings.achievementUnlockDates
        context.insert(newSettings)
        
        try context.save()
    }
}
