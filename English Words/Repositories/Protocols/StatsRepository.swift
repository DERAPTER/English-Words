//
//  StatsRepository.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation

@MainActor
protocol StatsRepository {
    // Settings
    func settings() throws -> UserSettings
    func updateDailyGoal(_ goal: Int) throws
    
    // Recording
    func recordSolved(on date: Date) throws -> StatsChange
    
    /// Помечает день как «SRS разгребён» и обновляет `srsStreak`.
    /// Идемпотентно: повторный вызов в тот же день ничего не меняет.
    func markSRSCleared(on date: Date) throws
    
    // Activity
    func activity(for date: Date) throws -> DailyStat?
    func activityHistory(monthsBack: Int) throws -> [DailyStat]
    func isDateActive(_ date: Date) throws -> Bool
    func totalDaysGoalCompleted() throws -> Int
    
    // Reset
    func resetAllStats() throws
}
