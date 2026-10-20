//
//  SRSWidgetSnapshotWriter.swift
//  English Words
//
//  Created by Егор Халиков on 09.10.2026.
//

import Foundation
import WidgetKit

/// Собирает актуальный снимок SRS-состояния из репозиториев
/// и сохраняет его в shared UserDefaults для виджета.
///
/// Вызывается при изменениях, влияющих на SRS:
/// - завершение SRS-сессии,
/// - добавление / удаление / редактирование карточек,
/// - сброс статистики,
/// - уход приложения в фон.
@MainActor
enum SRSWidgetSnapshotWriter {
    
    static func refresh(
        cardRepository: CardRepository,
        statsRepository: StatsRepository
    ) {
        let limit = UserDefaults.standard.integer(forKey: "srsNewCardsPerDay")
        let effectiveLimit = limit > 0 ? limit : 20
        
        let overview = try? cardRepository.srsOverview(
            on: .now,
            newCardsLimit: effectiveLimit
        )
        let streak = (try? statsRepository.settings().srsStreak) ?? 0
        
        let snapshot = SRSWidgetSnapshot(
            dueToday: overview?.dueToday ?? 0,
            srsStreak: streak,
            nextReviewDate: overview?.nextReviewDate,
            nextReviewCount: overview?.nextReviewCount ?? 0,
            updatedAt: .now
        )
        
        SRSWidgetStore.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
