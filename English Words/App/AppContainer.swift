//
//  AppContainer.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation
import SwiftData

/// DI-контейнер приложения.
/// Создаётся один раз в `English_WordsApp` и живёт через `Environment` до конца сессии.
///
/// Здесь собираются все репозитории и сервисы. ViewModel'и получают их через `init`.

@Observable
final class AppContainer {
    
    // MARK: - Repositories
    
    let cardRepository: CardRepository
    let groupRepository: GroupRepository
    let statsRepository: StatsRepository
    
    // MARK: - Services
    
    // (Появятся в следующих слоях: AchievementsService, SolveSessionStore)
    
    // MARK: - Init
    
    init(
        cardRepository: CardRepository,
        groupRepository: GroupRepository,
        statsRepository: StatsRepository
    ) {
        self.cardRepository = cardRepository
        self.groupRepository = groupRepository
        self.statsRepository = statsRepository
    }
    
    // MARK: - Factory
    
    static func live(container: ModelContainer) -> AppContainer {
        let context = container.mainContext
        
        return AppContainer(
            cardRepository: SwiftDataCardRepository(context: context),
            groupRepository: SwiftDataGroupRepository(context: context),
            statsRepository: SwiftDataStatsRepository(context: context)
        )
    }
}
