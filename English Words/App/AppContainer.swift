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

@MainActor
@Observable
final class AppContainer {
    
    // MARK: - Repositories
    
    let cardRepository: CardRepository
    let groupRepository: GroupRepository
    let statsRepository: StatsRepository
    
    // MARK: - Services
    
    let solveSessionStore: SolveSessionStore
    let solveSessionCoordinator: SolveSessionCoordinator
    
    // MARK: - Init
    
    init(
        cardRepository: CardRepository,
        groupRepository: GroupRepository,
        statsRepository: StatsRepository,
        solveSessionStore: SolveSessionStore,
        solveSessionCoordinator: SolveSessionCoordinator
    ) {
        self.cardRepository = cardRepository
        self.groupRepository = groupRepository
        self.statsRepository = statsRepository
        self.solveSessionStore = solveSessionStore
        self.solveSessionCoordinator = solveSessionCoordinator
    }
    
    // MARK: - Factory
    
    static func live(container: ModelContainer) -> AppContainer {
        let context = container.mainContext
        
        let cardRepo = SwiftDataCardRepository(context: context)
        let groupRepo = SwiftDataGroupRepository(context: context)
        let statsRepo = SwiftDataStatsRepository(context: context)
        
        let sessionStore = SolveSessionStore()
        let sessionCoordinator = SolveSessionCoordinator(
            store: sessionStore,
            cardRepository: cardRepo
        )
        
        return AppContainer(
            cardRepository: cardRepo,
            groupRepository: groupRepo,
            statsRepository: statsRepo,
            solveSessionStore: sessionStore,
            solveSessionCoordinator: sessionCoordinator
        )
    }
}
