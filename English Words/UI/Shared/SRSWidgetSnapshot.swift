//
//  SRSWidgetSnapshot.swift
//  English Words
//
//  Created by Егор Халиков on 09.10.2026.
//

import Foundation

/// Лёгкий снимок SRS-состояния для виджета.
///
/// Хранится в shared UserDefaults (`App Group`) и читается виджетом.
/// Обновляется приложением при каждом изменении SRS-состояния.
struct SRSWidgetSnapshot: Codable, Equatable {
    /// Сколько карточек нужно повторить сегодня (просроченные + новые в пределах лимита).
    let dueToday: Int
    
    /// Серия дней подряд с разгребённым SRS.
    let srsStreak: Int
    
    /// Ближайшая дата следующего повторения (для «всё повторено»).
    let nextReviewDate: Date?
    
    /// Сколько карточек на `nextReviewDate`.
    let nextReviewCount: Int
    
    /// Когда снимок был записан — для отладки и «устаревших» данных.
    let updatedAt: Date
    
    /// Пустой снимок — на случай, если приложение ещё ни разу не записало.
    static let empty = SRSWidgetSnapshot(
        dueToday: 0,
        srsStreak: 0,
        nextReviewDate: nil,
        nextReviewCount: 0,
        updatedAt: .distantPast
    )
}

// MARK: - Shared storage

enum SRSWidgetStore {
    
    static let appGroupID = "group.com.DERAPTER.English-Words"
    private static let key = "srs_widget_snapshot_v1"
    
    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    /// Записать снимок (вызывается из приложения).
    static func save(_ snapshot: SRSWidgetSnapshot) {
        guard let defaults, let data = try? JSONEncoder().encode(snapshot) else {
            return
        }
        defaults.set(data, forKey: key)
    }

    static func load() -> SRSWidgetSnapshot {
        guard let defaults else {
            return .empty
        }
        
        guard let data = defaults.data(forKey: key) else {
            return .empty
        }
        
        guard let snapshot = try? JSONDecoder().decode(SRSWidgetSnapshot.self, from: data) else {
            return .empty
        }
        
        return snapshot
    }
}
