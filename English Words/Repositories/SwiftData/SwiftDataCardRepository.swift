//
//  SwiftDataCardRepository.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataCardRepository: CardRepository {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Fetch
    
    func fetchAll() throws -> [Card] {
        let descriptor = FetchDescriptor<Card>(
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    func fetch(id: UUID) throws -> Card? {
        let predicate = #Predicate<Card> { $0.id == id }
        var descriptor = FetchDescriptor<Card>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            return try context.fetch(descriptor).first
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    func fetch(inGroup groupID: UUID) throws -> [Card] {
        let predicate = #Predicate<Card> { card in
            card.groups.contains { $0.id == groupID }
        }
        let descriptor = FetchDescriptor<Card>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    func fetchFavourites() throws -> [Card] {
        let predicate = #Predicate<Card> { $0.isFavourite == true }
        let descriptor = FetchDescriptor<Card>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    func search(_ query: String) throws -> [Card] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return try fetchAll() }
        
        let lower = trimmed.lowercased()
        let predicate = #Predicate<Card> { card in
            card.originWord.localizedStandardContains(lower) ||
            card.translatedWord.localizedStandardContains(lower)
        }
        let descriptor = FetchDescriptor<Card>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    // MARK: - Counts
    
    func totalCount() throws -> Int {
        do {
            return try context.fetchCount(FetchDescriptor<Card>())
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    func favouritesCount() throws -> Int {
        let predicate = #Predicate<Card> { $0.isFavourite == true }
        do {
            return try context.fetchCount(FetchDescriptor<Card>(predicate: predicate))
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    func count(inGroup groupID: UUID) throws -> Int {
        let predicate = #Predicate<Card> { card in
            card.groups.contains { $0.id == groupID }
        }
        do {
            return try context.fetchCount(FetchDescriptor<Card>(predicate: predicate))
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    // MARK: - Mutations
    
    func create(origin: String, translated: String, groups: [CardGroup]) throws -> Card {
        let trimmedOrigin = origin.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTranslated = translated.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedOrigin.isEmpty, !trimmedTranslated.isEmpty else {
            throw RepositoryError.invalidInput(reason: "Слово и перевод не могут быть пустыми")
        }
        
        let card = Card(origin: trimmedOrigin, translated: trimmedTranslated)
        card.groups = groups
        context.insert(card)
        try save()
        return card
    }
    
    func update(_ card: Card, origin: String, translated: String, groups: [CardGroup]) throws {
        let trimmedOrigin = origin.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTranslated = translated.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedOrigin.isEmpty, !trimmedTranslated.isEmpty else {
            throw RepositoryError.invalidInput(reason: "Слово и перевод не могут быть пустыми")
        }
        
        card.originWord = trimmedOrigin
        card.translatedWord = trimmedTranslated
        card.groups = groups
        try save()
    }
    
    func toggleFavourite(_ card: Card) throws {
        card.isFavourite.toggle()
        try save()
    }
    
    func delete(_ card: Card) throws {
        context.delete(card)
        try save()
    }
    
    func recordAnswer(_ card: Card, correct: Bool) throws {
        if correct {
            card.correctCount += 1
        } else {
            card.wrongCount += 1
        }
        try save()
    }
    
    // MARK: - Validation
    
    func exists(origin: String, translated: String, excluding cardID: UUID?) throws -> Bool {
        let lowerOrigin = origin.lowercased()
        let lowerTranslated = translated.lowercased()
        
        let descriptor = FetchDescriptor<Card>()
        do {
            let all = try context.fetch(descriptor)
            return all.contains { card in
                if let excludeID = cardID, card.id == excludeID { return false }
                return card.originWord.lowercased() == lowerOrigin &&
                       card.translatedWord.lowercased() == lowerTranslated
            }
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    // MARK: - Private
    
    private func save() throws {
        do {
            try context.save()
        } catch {
            throw RepositoryError.saveFailed(underlying: error)
        }
    }
}
