//
//  SolveSessionStore.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation

/// Хранилище незавершённых сессий нарешивания.
/// Сессии хранятся в UserDefaults как JSON-словарь [String: SolveSession].
@MainActor
final class SolveSessionStore {
    private let defaults: UserDefaults
    private let storageKey = "solve_sessions_v1"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - Public
    
    func load(for key: SolveGroupKey) -> SolveSession? {
        allSessions()[key.stringValue]
    }
    
    func save(_ session: SolveSession, for key: SolveGroupKey) {
        var dict = allSessions()
        dict[key.stringValue] = session
        persist(dict)
    }
    
    func clear(for key: SolveGroupKey) {
        var dict = allSessions()
        dict.removeValue(forKey: key.stringValue)
        persist(dict)
    }
    
    func clearAll() {
        defaults.removeObject(forKey: storageKey)
    }
    
    /// Все сохранённые сессии. Используется `SolveList` для показа индикаторов.
    func allSessionKeys() -> Set<SolveGroupKey> {
        Set(allSessions().keys.compactMap(SolveGroupKey.init(stringValue:)))
    }
    
    // MARK: - Private
    
    private func allSessions() -> [String: SolveSession] {
        guard let data = defaults.data(forKey: storageKey) else { return [:] }
        return (try? JSONDecoder().decode([String: SolveSession].self, from: data)) ?? [:]
    }
    
    private func persist(_ dict: [String: SolveSession]) {
        guard let data = try? JSONEncoder().encode(dict) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
