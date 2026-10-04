//
//  SolveSessionCoordinator.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation

/// Сервис для работы с сессией нарешивания.
/// Отвечает за подготовку сессии к актуальному состоянию карточек группы.
///
/// **SRS-режим — особый случай:**
/// - Сессия одноразовая: собирается из карточек, due на момент открытия.
/// - Не проходит через reconcile: новые карточки, появившиеся во время
///   сессии, не подтягиваются. Просроченные — тоже.
/// - После завершения сессии очищается, потому что все карточки
///   получили новое расписание.
@MainActor
final class SolveSessionCoordinator {
    private let store: SolveSessionStore
    private let cardRepository: CardRepository
    
    init(store: SolveSessionStore, cardRepository: CardRepository) {
        self.store = store
        self.cardRepository = cardRepository
    }
    
    /// Возвращает актуальную сессию для группы.
    func currentSession(for key: SolveGroupKey) throws -> SolveSession {
        // SRS — без reconcile
        if case .srs = key {
            if let existing = store.load(for: key) {
                return existing
            }
            let ids = try fetchCardIDs(for: key)
            let fresh = SolveSession(groupKey: key, cardIDs: ids)
            store.save(fresh, for: key)
            return fresh
        }
        
        // Остальные режимы — как раньше
        let currentCardIDs = try fetchCardIDs(for: key)
        
        guard var session = store.load(for: key) else {
            let fresh = SolveSession(groupKey: key, cardIDs: currentCardIDs)
            store.save(fresh, for: key)
            return fresh
        }
        
        session = reconcile(session: session, with: currentCardIDs)
        store.save(session, for: key)
        return session
    }
    
    /// Начать заново — полностью.
    func restartAll(for key: SolveGroupKey) throws -> SolveSession {
        let cardIDs = try fetchCardIDs(for: key)
        var session = SolveSession(groupKey: key, cardIDs: cardIDs)
        session.restartAll(from: cardIDs)
        store.save(session, for: key)
        return session
    }
    
    /// Начать заново с ошибок.
    func restartMistakes(_ session: SolveSession) -> SolveSession {
        var updated = session
        updated.restartMistakes()
        if let key = session.groupKey {
            store.save(updated, for: key)
        }
        return updated
    }
    
    func markCorrect(_ session: SolveSession) -> SolveSession {
        var updated = session
        updated.markCorrect()
        persistIfNeeded(updated)
        return updated
    }
    
    func markWrong(_ session: SolveSession) -> SolveSession {
        var updated = session
        updated.markWrong()
        persistIfNeeded(updated)
        return updated
    }
    
    func clear(for key: SolveGroupKey) {
        store.clear(for: key)
    }
    
    // MARK: - Private
    
    private func reconcile(session: SolveSession, with currentIDs: [UUID]) -> SolveSession {
        let currentSet = Set(currentIDs)
        var updated = session
        
        updated.unsolvedIDs = session.unsolvedIDs.filter { currentSet.contains($0) }
        updated.successIDs  = session.successIDs.filter  { currentSet.contains($0) }
        updated.failIDs     = session.failIDs.filter     { currentSet.contains($0) }
        
        let knownIDs = Set(updated.unsolvedIDs + updated.successIDs + updated.failIDs)
        let newIDs = currentIDs.filter { !knownIDs.contains($0) }
        updated.unsolvedIDs.append(contentsOf: newIDs.shuffled())
        
        return updated
    }
    
    private func persistIfNeeded(_ session: SolveSession) {
        guard let key = session.groupKey else { return }
        
        // Для SRS-сессии: как только все карточки отвечены — чистим.
        // Для остальных: чистим, когда всё правильно, без ошибок.
        if session.isCompletedWithoutMistakes {
            store.clear(for: key)
        } else {
            store.save(session, for: key)
        }
    }
    
    private func fetchCardIDs(for key: SolveGroupKey) throws -> [UUID] {
        switch key {
        case .system(.allCards):
            return try cardRepository.fetchAll().map(\.id)
        case .system(.favourites):
            return try cardRepository.fetchFavourites().map(\.id)
        case .user(let id):
            return try cardRepository.fetch(inGroup: id).map(\.id)
        case .srs:
            let limit = UserDefaults.standard.integer(forKey: "srsNewCardsPerDay")
            let effectiveLimit = limit > 0 ? limit : 20
            return try cardRepository
                .fetchDueToday(on: .now, newCardsLimit: effectiveLimit)
                .map(\.id)
        }
    }
}
