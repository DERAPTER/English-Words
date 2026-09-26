//
//  AchievementsService.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation

/// Сервис достижений.
///
/// Отвечает за:
/// - Формирование снимка статистики
/// - Проверку новых разблокировок
/// - Персистенцию факта разблокировки в `UserSettings`
/// - Публикацию события о разблокировке (для UI-уведомлений)
@MainActor
@Observable
final class AchievementsService {
    
    /// Список всех достижений с текущим статусом разблокировки.
    /// Обновляется после каждой проверки.
    private(set) var allAchievements: [AchievementStatus] = []
    
    /// Достижение, которое только что разблокировано. Используется UI для показа баннера.
    /// После показа — View зовёт `consumeRecentlyUnlocked()`.
    private(set) var recentlyUnlocked: Achievement?
    
    // MARK: - Dependencies
    
    private let statsRepository: StatsRepository
    private let cardRepository: CardRepository
    private let groupRepository: GroupRepository
    
    init(
        statsRepository: StatsRepository,
        cardRepository: CardRepository,
        groupRepository: GroupRepository
    ) {
        self.statsRepository = statsRepository
        self.cardRepository = cardRepository
        self.groupRepository = groupRepository
    }
    
    // MARK: - Public
    
    /// Пересчитывает состояние всех достижений и, при необходимости, разблокирует новые.
    /// Возвращает список только что разблокированных — для показа уведомлений.
    @discardableResult
    func evaluate() -> [Achievement] {
        do {
            let snapshot = try buildSnapshot()
            let settings = try statsRepository.settings()
            let alreadyUnlocked = Set(settings.unlockedAchievementIDs)
            
            let newlyUnlocked = AchievementsEvaluator.newlyUnlocked(
                snapshot: snapshot,
                alreadyUnlocked: alreadyUnlocked
            )
            
            for achievement in newlyUnlocked {
                settings.unlock(achievement.id)
            }
            
            // Обновляем published state
            rebuildStatusList(settings: settings)
            
            if let first = newlyUnlocked.first {
                recentlyUnlocked = first
            }
            
            return newlyUnlocked
        } catch {
            // В служебных целях можно логировать
            return []
        }
    }
    
    /// Загрузить состояние без проверки условий — для отображения в Profile.
    func refresh() {
        do {
            let settings = try statsRepository.settings()
            rebuildStatusList(settings: settings)
        } catch {
            // no-op
        }
    }
    
    /// Сбросить флаг "только что разблокировано" — View вызывает после показа баннера.
    func consumeRecentlyUnlocked() {
        recentlyUnlocked = nil
    }
    
    // MARK: - Private
    
    private func buildSnapshot() throws -> AchievementsSnapshot {
        let settings = try statsRepository.settings()
        let daysCompleted = try statsRepository.totalDaysGoalCompleted()
        
        return AchievementsSnapshot(
            cardsCreated: try cardRepository.totalCount(),
            cardsSolved: settings.totalSolved,
            streak: settings.streak,
            daysGoalCompleted: daysCompleted,
            favouritesCount: try cardRepository.favouritesCount(),
            userGroupsCount: try groupRepository.userGroupsCount()
        )
    }
    
    private func rebuildStatusList(settings: UserSettings) {
        let unlockedSet = Set(settings.unlockedAchievementIDs)
        
        allAchievements = AchievementsCatalog.all.map { achievement in
            AchievementStatus(
                achievement: achievement,
                isUnlocked: unlockedSet.contains(achievement.id),
                unlockedDate: settings.achievementUnlockDates[achievement.id]
            )
        }
    }
}

// MARK: - Display model

/// Обёртка достижения со статусом — для отображения в UI.
struct AchievementStatus: Identifiable {
    let achievement: Achievement
    let isUnlocked: Bool
    let unlockedDate: Date?
    
    var id: String { achievement.id }
}
