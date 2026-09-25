//
//  SolveSessionCoordinator.swift
//  English Words
//
//  Created by Егор Халиков on 25.09.2026.
//

import Foundation

/// Сервис для работы с сессией нарешивания.
/// Отвечает за подготовку сессии к актуальному состоянию карточек группы.
@MainActor
final class SolveSessionCoordinator {
    private let store: SolveSessionStore
    private let cardRepository: CardRepository
    
    init(store: SolveSessionStore, cardRepository: CardRepository) {
        self.store = store
        self.cardRepository = cardRepository
    }
    
    /// Возвращает актуальную сессию для группы.
    /// Если сохранённой сессии нет или она неактуальна — создаёт новую.
    /// Новые карточки (добавленные после старта сессии) добавляются в очередь.
    /// Удалённые карточки выбрасываются из сессии.
    func currentSession(for key: SolveGroupKey) throws -> SolveSession {
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
        store.save(updated, for: session.groupKey ?? .system(.allCards))
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
    
    /// Оставляем только те ID, которые ещё есть в группе,
    /// и добавляем новые карточки в очередь unsolved.
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
        // Если сессия завершена — не храним её, кроме случая с ошибками.
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
        }
    }
}
