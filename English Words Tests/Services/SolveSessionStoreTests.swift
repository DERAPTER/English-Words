//
//  SolveSessionStoreTests.swift
//  English Words Tests
//
//  Created by Егор Халиков on 06.10.2026.
//

import Testing
import Foundation
@testable import English_Words

@Suite("SolveSessionStore — хранение сессий в UserDefaults")
@MainActor
struct SolveSessionStoreTests {
    
    // MARK: - Fixture
    
    let defaults: UserDefaults
    let store: SolveSessionStore
    let suiteName: String
    
    init() {
        suiteName = "SolveSessionStoreTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        store = SolveSessionStore(defaults: defaults)
    }
    
    // MARK: - Helpers
    
    private func makeSession(
        key: SolveGroupKey = .system(.allCards),
        cardIDs: [UUID] = []
    ) -> SolveSession {
        SolveSession(groupKey: key, cardIDs: cardIDs)
    }
    
    // MARK: - load: пустое хранилище
    
    @Test("load: пустой store → nil")
    func loadEmptyStore() {
        #expect(store.load(for: .system(.allCards)) == nil)
        #expect(store.load(for: .srs) == nil)
        #expect(store.load(for: .user(UUID())) == nil)
    }
    
    // MARK: - save + load
    
    @Test("save → load возвращает ту же сессию")
    func saveAndLoadRoundTrip() {
        let session = makeSession(cardIDs: [UUID(), UUID()])
        store.save(session, for: .system(.allCards))
        
        let loaded = store.load(for: .system(.allCards))
        #expect(loaded == session)
    }
    
    @Test("save для SRS-ключа работает")
    func saveSRS() {
        let session = makeSession(key: .srs, cardIDs: [UUID()])
        store.save(session, for: .srs)
        #expect(store.load(for: .srs) == session)
    }
    
    @Test("save для user-ключа с UUID работает")
    func saveUserKey() {
        let userID = UUID()
        let session = makeSession(key: .user(userID), cardIDs: [UUID()])
        store.save(session, for: .user(userID))
        #expect(store.load(for: .user(userID)) == session)
    }
    
    @Test("save: повторное сохранение для того же ключа перезаписывает")
    func saveOverwrites() {
        var session = makeSession(cardIDs: [UUID(), UUID()])
        store.save(session, for: .system(.allCards))
        
        session.markCorrect()
        store.save(session, for: .system(.allCards))
        
        let loaded = store.load(for: .system(.allCards))
        #expect(loaded?.successIDs.count == 1)
        #expect(loaded == session)
    }
    
    @Test("save: разные ключи хранятся независимо")
    func saveMultipleKeysIndependently() {
        let s1 = makeSession(key: .system(.allCards), cardIDs: [UUID()])
        let s2 = makeSession(key: .system(.favourites), cardIDs: [UUID(), UUID()])
        let s3 = makeSession(key: .srs, cardIDs: [UUID(), UUID(), UUID()])
        
        store.save(s1, for: .system(.allCards))
        store.save(s2, for: .system(.favourites))
        store.save(s3, for: .srs)
        
        #expect(store.load(for: .system(.allCards)) == s1)
        #expect(store.load(for: .system(.favourites)) == s2)
        #expect(store.load(for: .srs) == s3)
    }
    
    @Test("save: сессия с прогрессом (success/fail) сохраняется и восстанавливается")
    func saveWithProgress() {
        var session = makeSession(cardIDs: [UUID(), UUID(), UUID()])
        session.markCorrect()
        session.markWrong()
        
        store.save(session, for: .srs)
        let loaded = store.load(for: .srs)
        
        #expect(loaded?.successIDs == session.successIDs)
        #expect(loaded?.failIDs == session.failIDs)
        #expect(loaded?.unsolvedIDs == session.unsolvedIDs)
    }
    
    // MARK: - clear
    
    @Test("clear: удаляет только указанный ключ")
    func clearRemovesOneKey() {
        store.save(makeSession(), for: .system(.allCards))
        store.save(makeSession(), for: .srs)
        
        store.clear(for: .system(.allCards))
        
        #expect(store.load(for: .system(.allCards)) == nil)
        #expect(store.load(for: .srs) != nil)
    }
    
    @Test("clear: несуществующий ключ — no-op")
    func clearNonExistentKey() {
        store.save(makeSession(), for: .srs)
        store.clear(for: .system(.allCards))
        #expect(store.load(for: .srs) != nil)
    }
    
    @Test("clear: на пустом store — не падает")
    func clearEmptyStore() {
        store.clear(for: .system(.allCards))
        #expect(store.load(for: .system(.allCards)) == nil)
    }
    
    // MARK: - clearAll
    
    @Test("clearAll: удаляет все сессии")
    func clearAllRemovesEverything() {
        store.save(makeSession(), for: .system(.allCards))
        store.save(makeSession(), for: .system(.favourites))
        store.save(makeSession(key: .srs, cardIDs: [UUID()]), for: .srs)
        
        store.clearAll()
        
        #expect(store.load(for: .system(.allCards)) == nil)
        #expect(store.load(for: .system(.favourites)) == nil)
        #expect(store.load(for: .srs) == nil)
        #expect(store.allSessionKeys().isEmpty)
    }
    
    @Test("clearAll: на пустом store — не падает")
    func clearAllEmpty() {
        store.clearAll()
        #expect(store.allSessionKeys().isEmpty)
    }
    
    // MARK: - allSessionKeys
    
    @Test("allSessionKeys: пустой store → пустое множество")
    func allSessionKeysEmpty() {
        #expect(store.allSessionKeys().isEmpty)
    }
    
    @Test("allSessionKeys: возвращает все сохранённые ключи")
    func allSessionKeysReturnsAll() {
        let userID = UUID()
        store.save(makeSession(key: .system(.allCards)), for: .system(.allCards))
        store.save(makeSession(key: .system(.favourites)), for: .system(.favourites))
        store.save(makeSession(key: .user(userID)), for: .user(userID))
        store.save(makeSession(key: .srs), for: .srs)
        
        let keys = store.allSessionKeys()
        #expect(keys.count == 4)
        #expect(keys.contains(.system(.allCards)))
        #expect(keys.contains(.system(.favourites)))
        #expect(keys.contains(.user(userID)))
        #expect(keys.contains(.srs))
    }
    
    @Test("allSessionKeys: после clear одного — остальные на месте")
    func allSessionKeysAfterClear() {
        store.save(makeSession(), for: .system(.allCards))
        store.save(makeSession(key: .srs), for: .srs)
        
        store.clear(for: .srs)
        
        let keys = store.allSessionKeys()
        #expect(keys == [.system(.allCards)])
    }
    
    // MARK: - Изоляция между suite
    
    @Test("Разные UserDefaults suite — изолированные хранилища")
    func differentSuitesAreIsolated() {
        let otherSuiteName = "SolveSessionStoreTests-\(UUID().uuidString)"
        let otherDefaults = UserDefaults(suiteName: otherSuiteName)!
        defer { otherDefaults.removePersistentDomain(forName: otherSuiteName) }
        
        let otherStore = SolveSessionStore(defaults: otherDefaults)
        
        store.save(makeSession(key: .srs), for: .srs)
        
        // В другом suite — пусто
        #expect(otherStore.load(for: .srs) == nil)
    }
    
    // MARK: - Персистентность между инстансами
    
    @Test("Новый store на том же suite читает сохранённые данные")
    func persistsAcrossInstances() {
        let session = makeSession(cardIDs: [UUID(), UUID()])
        store.save(session, for: .system(.allCards))
        
        // Создаём новый store на том же suite
        let anotherStore = SolveSessionStore(defaults: defaults)
        #expect(anotherStore.load(for: .system(.allCards)) == session)
    }
    
    // MARK: - Повреждённые данные
    
    @Test("Повреждённые данные в UserDefaults → все методы возвращают пустые значения, не падает")
    func corruptedDataGraceful() {
        // Кладём мусор в ключ хранилища
        let garbage = "not-a-valid-json".data(using: .utf8)!
        defaults.set(garbage, forKey: "solve_sessions_v1")
        
        // Все методы должны работать без краша
        #expect(store.load(for: .system(.allCards)) == nil)
        #expect(store.allSessionKeys().isEmpty)
        
        // clear не падает
        store.clear(for: .srs)
        #expect(store.load(for: .srs) == nil)
        
        // save продолжает работать — перезаписывает мусор валидным JSON
        let session = makeSession()
        store.save(session, for: .system(.allCards))
        #expect(store.load(for: .system(.allCards)) == session)
    }
    
    @Test("Данные неизвестного формата в UserDefaults (не Data) → не падает")
    func wrongTypeGraceful() {
        // Кладём строку вместо Data
        defaults.set("just-a-string", forKey: "solve_sessions_v1")
        
        #expect(store.load(for: .system(.allCards)) == nil)
        #expect(store.allSessionKeys().isEmpty)
    }
    
    // MARK: - Сквозные сценарии
    
    @Test("Сценарий: сохранили → отметили карточку → перезаписали → прочитали")
    func markAndPersist() {
        let cardIDs = [UUID(), UUID(), UUID()]
        var session = makeSession(key: .srs, cardIDs: cardIDs)
        store.save(session, for: .srs)
        
        session.markCorrect()
        store.save(session, for: .srs)
        
        let loaded = store.load(for: .srs)
        #expect(loaded?.successIDs.count == 1)
        #expect(loaded?.unsolvedIDs.count == 2)
        #expect(loaded?.totalCount == 3)
    }
    
    @Test("Сценарий: 4 разных сессии + clearAll → всё чисто")
    func multiSessionThenClearAll() {
        let keys: [SolveGroupKey] = [
            .system(.allCards),
            .system(.favourites),
            .user(UUID()),
            .srs
        ]
        
        for key in keys {
            store.save(makeSession(key: key, cardIDs: [UUID()]), for: key)
        }
        #expect(store.allSessionKeys().count == 4)
        
        store.clearAll()
        #expect(store.allSessionKeys().isEmpty)
        
        for key in keys {
            #expect(store.load(for: key) == nil)
        }
    }
}
