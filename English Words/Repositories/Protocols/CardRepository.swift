//
//  CardRepository.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation

protocol CardRepository {
    // Fetch
    func fetchAll() throws -> [Card]
    func fetch(id: UUID) throws -> Card?
    func fetch(inGroup groupID: UUID) throws -> [Card]
    func fetchFavourites() throws -> [Card]
    func search(_ query: String) throws -> [Card]
    
    // Counts
    func totalCount() throws -> Int
    func favouritesCount() throws -> Int
    func count(inGroup groupID: UUID) throws -> Int
    
    // Mutations
    func create(origin: String, translated: String, groups: [CardGroup]) throws -> Card
    func update(_ card: Card, origin: String, translated: String, groups: [CardGroup]) throws
    func toggleFavourite(_ card: Card) throws
    func delete(_ card: Card) throws
    func recordAnswer(_ card: Card, correct: Bool) throws
    
    // Validation
    func exists(origin: String, translated: String, excluding cardID: UUID?) throws -> Bool
}
