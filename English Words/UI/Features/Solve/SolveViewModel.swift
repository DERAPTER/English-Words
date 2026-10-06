//
//  SolveViewModel.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class SolveViewModel {
    
    enum SolveState {
        case solving
        case completedWithoutMistakes
        case completedWithMistakes
        case empty
    }
    
    enum SwipeDecision {
        case flyLeft
        case flyRight
        case reset
    }
    
    // MARK: - Session
    
    private(set) var session: SolveSession
    private(set) var currentCard: Card?
    private var cardsByID: [UUID: Card] = [:]
    
    // MARK: - UI state (свайп-режим)
    
    var offsetOfCardX: CGFloat = 0
    var offsetOfCardY: CGFloat = 0
    private(set) var percentageOfMove: Double = 0
    
    private enum SwipeSide {
        case none, left, right
    }
    private var currentSwipeSide: SwipeSide = .none
    
    // MARK: - UI state (SRS-режим)
    
    var isCardFlipped: Bool = false
    
    // MARK: - Alerts
    
    var showUnfinishedSessionAlert = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    
    let key: SolveGroupKey
    private let title: String
    private let cardRepository: CardRepository
    private let statsRepository: StatsRepository
    private let sessionCoordinator: SolveSessionCoordinator
    private let achievementsService: AchievementsService
    
    // MARK: - Constants
    
    private let swipeThreshold: CGFloat = 60
    private let colorThreshold: CGFloat = 30
    
    // MARK: - Init
    
    init(
        key: SolveGroupKey,
        title: String,
        cardRepository: CardRepository,
        statsRepository: StatsRepository,
        sessionCoordinator: SolveSessionCoordinator,
        achievementsService: AchievementsService
    ) {
        self.key = key
        self.title = title
        self.cardRepository = cardRepository
        self.statsRepository = statsRepository
        self.sessionCoordinator = sessionCoordinator
        self.achievementsService = achievementsService
        
        self.session = SolveSession(groupKey: key, cardIDs: [])
    }
    
    // MARK: - Derived
    
    var isSRSMode: Bool {
        if case .srs = key { return true }
        return false
    }
    
    var groupTitle: String {
        if isSRSMode {
            return "srs_review_title".localized()
        }
        return title
    }
    
    var state: SolveState {
        if session.totalCount == 0 { return .empty }
        if session.isCompletedWithMistakes { return .completedWithMistakes }
        if session.isCompletedWithoutMistakes { return .completedWithoutMistakes }
        return .solving
    }
    
    var currentProgress: Int { session.solvedCount + 1 }
    var totalProgress: Int { session.totalCount }
    var successCount: Int { session.successIDs.count }
    var failCount: Int { session.failIDs.count }
    
    var progressFraction: Double {
        let total = session.totalCount
        guard total > 0 else { return 0 }
        return Double(session.successIDs.count) / Double(total)
    }
    
    // MARK: - Lifecycle
    
    func onAppear() {
        do {
            let loaded = try sessionCoordinator.currentSession(for: key)
            session = loaded
            try reloadCards()
            updateCurrentCard()
            
            if !isSRSMode && session.isUnfinished {
                showUnfinishedSessionAlert = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Session control (свайп-режим)
    
    func continueSession() {
        showUnfinishedSessionAlert = false
    }
    
    func startOver() {
        showUnfinishedSessionAlert = false
        do {
            session = try sessionCoordinator.restartAll(for: key)
            try reloadCards()
            updateCurrentCard()
            resetOffsets()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func restartFromResult() {
        do {
            session = try sessionCoordinator.restartAll(for: key)
            try reloadCards()
            updateCurrentCard()
            resetOffsets()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func restartMistakesFromResult() {
        session = sessionCoordinator.restartMistakes(session)
        updateCurrentCard()
        resetOffsets()
    }
    
    // MARK: - Swipe handling (не-SRS режим)
    
    func onDragChanged(_ value: DragGesture.Value) {
        offsetOfCardX = value.translation.width
        offsetOfCardY = value.translation.height
        
        let t = value.translation.width
        if t < -colorThreshold {
            percentageOfMove = max(-1, (t + colorThreshold) / 70)
        } else if t > colorThreshold {
            percentageOfMove = min(1, (t - colorThreshold) / 70)
        } else {
            percentageOfMove = 0
        }
        
        // Определяем текущую сторону
        let newSide: SwipeSide
        if t < -colorThreshold {
            newSide = .left
        } else if t > colorThreshold {
            newSide = .right
        } else {
            newSide = .none
        }
        
        // Вибро — при входе в зону или при перескоке через центр на другую сторону.
        // Уход в .none (ободок гаснет) отклика не даёт.
        if newSide != currentSwipeSide {
            if newSide != .none {
                HapticService.shared.lightImpact()
            }
            currentSwipeSide = newSide
        }
    }
    
    func onDragEnded(_ value: DragGesture.Value) -> SwipeDecision {
        let t = value.translation.width
        let p = value.predictedEndTranslation.width
        
        if t < -swipeThreshold || p < -swipeThreshold {
            return .flyLeft
        } else if t > swipeThreshold || p > swipeThreshold {
            return .flyRight
        } else {
            return .reset
        }
    }
    
    func commitSwipe(_ decision: SwipeDecision) async {
        switch decision {
        case .flyLeft:  await commitWrong()
        case .flyRight: await commitCorrect()
        case .reset:    resetOffsets()
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
    
    /// Оценка карточки в SRS-режиме.
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
        
        // Тактильный отклик: успех / ошибка
        if quality.isCorrect {
            HapticService.shared.success()
        } else {
            HapticService.shared.error()
        }
        
        session = sessionCoordinator.markCorrect(session)
        
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
    
    private func commitCorrect() async {
        guard let card = currentCard else {
            resetOffsets()
            return
        }
        
        do {
            try cardRepository.recordAnswer(card, correct: true)
            _ = try statsRepository.recordSolved(on: .now)
            _ = achievementsService.evaluate()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        HapticService.shared.success()
        
        session = sessionCoordinator.markCorrect(session)
        try? await Task.sleep(for: .milliseconds(200))
        resetOffsets()
        updateCurrentCard()
    }
    
    private func commitWrong() async {
        guard let card = currentCard else {
            resetOffsets()
            return
        }
        
        do {
            try cardRepository.recordAnswer(card, correct: false)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        HapticService.shared.error()
        
        session = sessionCoordinator.markWrong(session)
        try? await Task.sleep(for: .milliseconds(200))
        resetOffsets()
        updateCurrentCard()
    }
    
    private func resetOffsets() {
        offsetOfCardX = 0
        offsetOfCardY = 0
        percentageOfMove = 0
        currentSwipeSide = .none
    }
    
    private func reloadCards() throws {
        let allCards: [Card]
        switch key {
        case .system(.allCards):
            allCards = try cardRepository.fetchAll()
        case .system(.favourites):
            allCards = try cardRepository.fetchFavourites()
        case .user(let id):
            allCards = try cardRepository.fetch(inGroup: id)
        case .srs:
            allCards = try cardRepository.fetchAll()
        }
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
