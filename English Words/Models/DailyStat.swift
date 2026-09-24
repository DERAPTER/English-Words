//
//  DailyStat.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation
import SwiftData

/// Одна запись = один день активности.
/// `dateKey` используется как уникальный ключ ("yyyy-MM-dd").
@Model
final class DailyStat {
    @Attribute(.unique) var dateKey: String
    var date: Date
    var solvedCount: Int
    var goalCompleted: Bool
    
    init(
        date: Date,
        solvedCount: Int = 0,
        goalCompleted: Bool = false
    ) {
        self.dateKey = Self.makeKey(for: date)
        self.date = Calendar.current.startOfDay(for: date)
        self.solvedCount = solvedCount
        self.goalCompleted = goalCompleted
    }
    
    static func makeKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}
