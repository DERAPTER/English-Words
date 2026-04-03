//
//  Card.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

class Card: Identifiable, ObservableObject, Equatable, Codable {
    
    let id: UUID
    @Published var originWord: String
    @Published var translatedWord: String
    @Published var groups: [String]
    
    let dateAdded: Date
    
    @Published var correctCount: Int
    @Published var wrongCount: Int
    
    var isFavourite: Bool {
        groups.contains("Favourites")
    }
    
    func addNewGroup(groupName: String) {
        if !groups.contains(groupName) {
            groups.append(groupName)
        }
    }
    
    func removeGroup(groupName: String) {
        groups.removeAll { $0 == groupName }
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
    
    init(origin: String, translate: String) {
        self.id = UUID()
        self.originWord = origin
        self.translatedWord = translate
        self.dateAdded = Date()
        self.groups = []
        self.correctCount = 0
        self.wrongCount = 0
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, originWord, translatedWord, groups, dateAdded, correctCount, wrongCount
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        originWord = try container.decode(String.self, forKey: .originWord)
        translatedWord = try container.decode(String.self, forKey: .translatedWord)
        groups = try container.decode([String].self, forKey: .groups)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        correctCount = try container.decode(Int.self, forKey: .correctCount)
        wrongCount = try container.decode(Int.self, forKey: .wrongCount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(originWord, forKey: .originWord)
        try container.encode(translatedWord, forKey: .translatedWord)
        try container.encode(groups, forKey: .groups)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encode(correctCount, forKey: .correctCount)
        try container.encode(wrongCount, forKey: .wrongCount)
    }
}
