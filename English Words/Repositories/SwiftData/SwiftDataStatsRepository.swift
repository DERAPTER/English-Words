//
//  SwiftDataStatsRepository.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataStatsRepository: StatsRepository {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
        try? ensureSingletonExists()
    }
    
    // MARK: - Settings
    
    func settings() throws -> UserSettings {
        let predicate = #Predicate<UserSettings> { $0.id == "singleton" }
        var descriptor = FetchDescriptor<UserSettings>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            if let existing = try context.fetch(descriptor).first {
                return existing
            }
            let created = UserSettings()
            context.insert(created)
            try context.save()
            return created
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    func updateDailyGoal(_ goal: Int) throws {
        let clamped = max(1, min(100, goal))
        let s = try settings()
        s.dailyGoal = clamped
        try save()
    }
    
    // MARK: - Recording
    
    func recordSolved(on date: Date) throws -> StatsChange {
        let s = try settings()
        let calendar = Calendar.current
        
        // Проверяем смену дня
        if !calendar.isDate(s.lastActiveDate, inSameDayAs: date) {
            s.lastActiveDate = date
            s.dailyGoalRewarded = false
        }
        
        // Обновляем/создаём запись за сегодня
        let todayStat = try statForDate(date) ?? {
            let created = DailyStat(date: date)
            context.insert(created)
            return created
        }()
        
        todayStat.solvedCount += 1
        s.totalSolved += 1
        
        // Проверяем достижение цели
        let goalJustCompleted = !todayStat.goalCompleted && todayStat.solvedCount >= s.dailyGoal
        if goalJustCompleted {
            todayStat.goalCompleted = true
            if !s.dailyGoalRewarded {
                s.dailyGoalRewarded = true
            }
            updateStreak(settings: s, date: date)
        }
        
        try save()
        
        return StatsChange(
            goalJustCompleted: goalJustCompleted,
            newStreak: s.streak,
            newTotalSolved: s.totalSolved,
            newTodaySolved: todayStat.solvedCount,
            dailyGoal: s.dailyGoal
        )
    }
    
    // MARK: - Activity
    
    func activity(for date: Date) throws -> DailyStat? {
        try statForDate(date)
    }
    
    func activityHistory(monthsBack: Int) throws -> [DailyStat] {
        let calendar = Calendar.current
        guard let from = calendar.date(byAdding: .month, value: -monthsBack, to: .now) else {
            return []
        }
        let predicate = #Predicate<DailyStat> { $0.date >= from }
        let descriptor = FetchDescriptor<DailyStat>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    func isDateActive(_ date: Date) throws -> Bool {
        try statForDate(date)?.goalCompleted ?? false
    }
    
    func totalDaysGoalCompleted() throws -> Int {
        let predicate = #Predicate<DailyStat> { $0.goalCompleted == true }
        do {
            return try context.fetchCount(FetchDescriptor<DailyStat>(predicate: predicate))
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    // MARK: - Reset
    
    func resetAllStats() throws {
        do {
            let stats = try context.fetch(FetchDescriptor<DailyStat>())
            for stat in stats {
                context.delete(stat)
            }
            
            let s = try settings()
            s.streak = 0
            s.totalSolved = 0
            s.lastActiveDate = .now
            s.dailyGoalRewarded = false
            
            try context.save()
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.saveFailed(underlying: error)
        }
    }
    
    // MARK: - Private
    
    private func statForDate(_ date: Date) throws -> DailyStat? {
        let key = DailyStat.makeKey(for: date)
        let predicate = #Predicate<DailyStat> { $0.dateKey == key }
        var descriptor = FetchDescriptor<DailyStat>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            return try context.fetch(descriptor).first
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    private func ensureSingletonExists() throws {
        let predicate = #Predicate<UserSettings> { $0.id == "singleton" }
        let descriptor = FetchDescriptor<UserSettings>(predicate: predicate)
        let count = try context.fetchCount(descriptor)
        if count == 0 {
            context.insert(UserSettings())
            try context.save()
        }
    }
    
    /// Обновляет streak. Логика:
    /// - если вчерашний день был активен — увеличиваем
    /// - если активных дней нет — streak = 1
    /// - если был перерыв — streak = 1
    private func updateStreak(settings: UserSettings, date: Date) {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        let yesterdayKey = DailyStat.makeKey(for: yesterday)
        
        let predicate = #Predicate<DailyStat> { $0.dateKey == yesterdayKey && $0.goalCompleted == true }
        let descriptor = FetchDescriptor<DailyStat>(predicate: predicate)
        let yesterdayWasActive = (try? context.fetchCount(descriptor)) ?? 0 > 0
        
        if yesterdayWasActive {
            settings.streak += 1
        } else {
            // Проверим, есть ли вообще активные дни до сегодня
            let todayKey = DailyStat.makeKey(for: date)
            let anyActivePredicate = #Predicate<DailyStat> { $0.goalCompleted == true && $0.dateKey != todayKey }
            let anyActive = (try? context.fetchCount(FetchDescriptor<DailyStat>(predicate: anyActivePredicate))) ?? 0 > 0
            settings.streak = anyActive ? 1 : 1
        }
    }
    
    private func save() throws {
        do {
            try context.save()
        } catch {
            throw RepositoryError.saveFailed(underlying: error)
        }
    }
}
