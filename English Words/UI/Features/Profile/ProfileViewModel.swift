//
//  ProfileViewModel.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation

@MainActor
@Observable
final class ProfileViewModel {
    
    struct Stats {
        var dailyGoal: Int = 20
        var todaySolved: Int = 0
        var streak: Int = 0
        var totalSolved: Int = 0
        var totalCards: Int = 0
        var userGroupsCount: Int = 0
        var favouritesCount: Int = 0
        var totalDaysGoalCompleted: Int = 0
        
        var dailyProgress: Double {
            guard dailyGoal > 0 else { return 0 }
            return min(Double(todaySolved) / Double(dailyGoal), 1.0)
        }
        
        var todayGoalCompleted: Bool {
            todaySolved >= dailyGoal
        }
    }
    
    // MARK: - State
    
    private(set) var stats = Stats()
    private(set) var activityHistory: [DailyStat] = []
    private(set) var achievements: [AchievementStatus] = []
    
    var isStatisticsExpanded = false
    var isCalendarExpanded = false
    var isAchievementsExpanded = false
    var showAllAchievements = false
    var showingGoalEditor = false
    
    var goalEditorValue: Int = 20
    
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let statsRepository: StatsRepository
    private let cardRepository: CardRepository
    private let groupRepository: GroupRepository
    private let achievementsService: AchievementsService
    
    init(
        statsRepository: StatsRepository,
        cardRepository: CardRepository,
        groupRepository: GroupRepository,
        achievementsService: AchievementsService
    ) {
        self.statsRepository = statsRepository
        self.cardRepository = cardRepository
        self.groupRepository = groupRepository
        self.achievementsService = achievementsService
    }
    
    // MARK: - Lifecycle
    
    func load() {
        do {
            let settings = try statsRepository.settings()
            let todayStat = try statsRepository.activity(for: .now)
            
            // Учитываем смену дня: если дата lastActiveDate != сегодня,
            // сегодняшнее количество = 0.
            let todaySolved: Int
            if Calendar.current.isDate(settings.lastActiveDate, inSameDayAs: .now) {
                todaySolved = todayStat?.solvedCount ?? 0
            } else {
                todaySolved = 0
            }
            
            stats = Stats(
                dailyGoal: settings.dailyGoal,
                todaySolved: todaySolved,
                streak: settings.streak,
                totalSolved: settings.totalSolved,
                totalCards: try cardRepository.totalCount(),
                userGroupsCount: try groupRepository.userGroupsCount(),
                favouritesCount: try cardRepository.favouritesCount(),
                totalDaysGoalCompleted: try statsRepository.totalDaysGoalCompleted()
            )
            
            activityHistory = try statsRepository.activityHistory(monthsBack: 12)
            achievementsService.refresh()
            achievements = achievementsService.allAchievements
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Goal editor
    
    func openGoalEditor() {
        goalEditorValue = stats.dailyGoal
        showingGoalEditor = true
    }
    
    func saveGoal(_ value: Int) {
        do {
            try statsRepository.updateDailyGoal(value)
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Calendar
    
    func isDateActive(_ date: Date) -> Bool {
        let key = DailyStat.makeKey(for: date)
        return activityHistory.first(where: { $0.dateKey == key })?.goalCompleted ?? false
    }
    
    // MARK: - Achievements
    
    var unlockedAchievements: [AchievementStatus] {
        achievements.filter(\.isUnlocked)
    }
    
    var achievementsPreview: [AchievementStatus] {
        Array(unlockedAchievements.prefix(10))
    }
}
