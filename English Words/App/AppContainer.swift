//
//  AppContainer.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

//
//  AppContainer.swift
//  English Words
//

import Foundation
import SwiftData

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
    let achievementsService: AchievementsService
    
    // MARK: - Init
    
    init(
        cardRepository: CardRepository,
        groupRepository: GroupRepository,
        statsRepository: StatsRepository,
        solveSessionStore: SolveSessionStore,
        solveSessionCoordinator: SolveSessionCoordinator,
        achievementsService: AchievementsService
    ) {
        self.cardRepository = cardRepository
        self.groupRepository = groupRepository
        self.statsRepository = statsRepository
        self.solveSessionStore = solveSessionStore
        self.solveSessionCoordinator = solveSessionCoordinator
        self.achievementsService = achievementsService
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
        
        let achievementsService = AchievementsService(
            statsRepository: statsRepo,
            cardRepository: cardRepo,
            groupRepository: groupRepo
        )
        
        return AppContainer(
            cardRepository: cardRepo,
            groupRepository: groupRepo,
            statsRepository: statsRepo,
            solveSessionStore: sessionStore,
            solveSessionCoordinator: sessionCoordinator,
            achievementsService: achievementsService
        )
    }
}
