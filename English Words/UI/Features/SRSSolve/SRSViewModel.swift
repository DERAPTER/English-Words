//
//  SRSViewModel.swift
//  English Words
//
//  Created by Егор Халиков on 07.10.2026.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class SRSViewModel {
    
    enum SRSState {
        case solving
        case completed
        case empty
    }
    
    // MARK: - Session
    
    private(set) var session: SolveSession
    private(set) var currentCard: Card?
    private var cardsByID: [UUID: Card] = [:]
    
    // MARK: - UI state
    
    var isCardFlipped: Bool = false
    
    // MARK: - Errors
    
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let key: SolveGroupKey = .srs
    private let cardRepository: CardRepository
    private let statsRepository: StatsRepository
    private let sessionCoordinator: SolveSessionCoordinator
    private let achievementsService: AchievementsService
    
    // MARK: - Init
    
    init(
        cardRepository: CardRepository,
        statsRepository: StatsRepository,
        sessionCoordinator: SolveSessionCoordinator,
        achievementsService: AchievementsService
    ) {
        self.cardRepository = cardRepository
        self.statsRepository = statsRepository
        self.sessionCoordinator = sessionCoordinator
        self.achievementsService = achievementsService
        
        self.session = SolveSession(groupKey: .srs, cardIDs: [])
    }
    
    // MARK: - Derived
    
    var state: SRSState {
        if session.totalCount == 0 { return .empty }
        if session.isCompletedWithoutMistakes { return .completed }
        return .solving
    }
    
    var currentProgress: Int { session.solvedCount + 1 }
    var totalProgress: Int { session.totalCount }
    var reviewedCount: Int { session.solvedCount }
    
    // MARK: - Lifecycle
    
    func onAppear() {
        do {
            let loaded = try sessionCoordinator.currentSession(for: key)
            session = loaded
            try reloadCards()
            updateCurrentCard()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - SRS handling
    
    func intervalPreviews() -> [SRSQuality: Int] {
        guard let card = currentCard else { return [:] }
        var result: [SRSQuality: Int] = [:]
        for q in SRSQuality.allCases {
            result[q] = SRSAlgorithm.previewIntervalDays(
                quality: q.rawValue,
                currentEaseFactor: card.easeFactor,
                currentIntervalDays: card.intervalDays,
                currentRepetitions: card.repetitions
            )
        }
        return result
    }
    
    func rateCurrentCard(_ quality: SRSQuality) async {
        guard let card = currentCard else { return }
        
        do {
            try cardRepository.recordSRSReview(card, quality: quality.rawValue, on: .now)
            
            if quality.isCorrect {
                _ = try statsRepository.recordSolved(on: .now)
                _ = achievementsService.evaluate()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        if quality.isCorrect {
            HapticService.shared.success()
        } else {
            HapticService.shared.error()
        }
        
        session = sessionCoordinator.markCorrect(session)
        
        // Если это последний ответ в сессии — проверить,
        // не разгрёб ли пользователь всю SRS-очередь.
        if session.isCompletedWithoutMistakes {
            tryMarkSRSClearedIfDone()
        }
        
        try? await Task.sleep(for: .milliseconds(150))
        isCardFlipped = false
        updateCurrentCard()
    }
    
    // MARK: - Card favourite
    
    func toggleFavouriteCurrentCard() {
        guard let card = currentCard else { return }
        do {
            try cardRepository.toggleFavourite(card)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Private
    
    /// Если все SRS-карточки на сегодня разгребены — помечаем день
    /// и обновляем `srsStreak`.
    private func tryMarkSRSClearedIfDone() {
        let limit = UserDefaults.standard.integer(forKey: "srsNewCardsPerDay")
        let effectiveLimit = limit > 0 ? limit : 20
        do {
            let overview = try cardRepository.srsOverview(
                on: .now,
                newCardsLimit: effectiveLimit
            )
            if overview.dueToday == 0 {
                try statsRepository.markSRSCleared(on: .now)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func reloadCards() throws {
        let allCards = try cardRepository.fetchAll()
        cardsByID = Dictionary(uniqueKeysWithValues: allCards.map { ($0.id, $0) })
    }
    
    private func updateCurrentCard() {
        guard let id = session.currentCardID else {
            currentCard = nil
            return
        }
        currentCard = cardsByID[id]
    }
}
