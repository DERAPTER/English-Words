//
//  CardsManager.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct CardsGroup: Identifiable, Hashable, Codable {
    let id = UUID()
    var name: String
    var cards: Cards
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CardsGroup, rhs: CardsGroup) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case name, cards
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        cards = try container.decode(Cards.self, forKey: .cards)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(cards, forKey: .cards)
    }
    
    init(name: String, cards: Cards) {
        self.name = name
        self.cards = cards
    }
}

class CardsManager: ObservableObject {
    @Published var groups: [CardsGroup] = []
    
    // MARK: - Daily Goal & Statistics
    @AppStorage("dailyGoal") var dailyGoal: Int = 20
    @AppStorage("todaySolved") var todaySolvedRaw: Int = 0
    @AppStorage("lastActiveDate") private var lastActiveDate: Double = Date().timeIntervalSince1970
    @AppStorage("streak") var streak: Int = 0
    @AppStorage("totalSolved") var totalSolved: Int = 0
    @AppStorage("activityHistory") private var activityHistoryRaw: String = "{}"
    
    var activityHistory: [String: Bool] {
        get {
            guard let data = activityHistoryRaw.data(using: .utf8),
                  let dict = try? JSONDecoder().decode([String: Bool].self, from: data) else {
                return [:]
            }
            return dict
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let jsonString = String(data: data, encoding: .utf8) {
                activityHistoryRaw = jsonString
            }
            saveToFile()
        }
    }
    
    var todaySolved: Int {
        get {
            checkAndResetDaily()
            return todaySolvedRaw
        }
        set {
            todaySolvedRaw = newValue
            saveToFile()
        }
    }
    
    var dailyProgress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(todaySolved) / Double(dailyGoal), 1.0)
    }
    
    private func checkAndResetDaily() {
        let lastDate = Date(timeIntervalSince1970: lastActiveDate)
        let calendar = Calendar.current
        
        if !calendar.isDateInToday(lastDate) {
            if calendar.isDateInYesterday(lastDate) && todaySolvedRaw > 0 {
                streak += 1
            } else if !calendar.isDateInYesterday(lastDate) && todaySolvedRaw > 0 {
                streak = 1
            }
            todaySolvedRaw = 0
            lastActiveDate = Date().timeIntervalSince1970
            saveToFile()
        }
    }
    
    func recordSolvedCard() {
        checkAndResetDaily()
        todaySolvedRaw += 1
        totalSolved += 1
        
        let today = Date()
        let dateString = formatDate(today)
        var history = activityHistory
        history[dateString] = true
        activityHistory = history
        saveToFile()
    }
    
    func updateDailyGoal(_ newGoal: Int) {
        dailyGoal = max(1, min(100, newGoal))
        saveToFile()
    }
    
    func isDateActive(_ date: Date) -> Bool {
        let dateString = formatDate(date)
        return activityHistory[dateString] == true
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Statistics
    var totalCardsCount: Int {
        groups.first { $0.name == "All Cards" }?.cards.cardsArr.count ?? 0
    }
    
    var favouritesCount: Int {
        groups.first { $0.name == "Favourites" }?.cards.cardsArr.count ?? 0
    }
    
    // MARK: - Data Persistence
    private func saveToFile() {
        DataManager.shared.saveData(groups: groups)
        
        // Сохраняем статистику отдельно
        DataManager.shared.saveStatistics(
            dailyGoal: dailyGoal,
            streak: streak,
            totalSolved: totalSolved,
            activityHistory: activityHistory
        )
    }
    
    private func loadFromFile() {
        if let savedGroups = DataManager.shared.loadData() {
            self.groups = savedGroups
        } else {
            createDefaultData()
        }
        
        // Загружаем статистику
        let stats = DataManager.shared.loadStatistics()
        if stats.dailyGoal != 20 || stats.streak != 0 || stats.totalSolved != 0 {
            self.dailyGoal = stats.dailyGoal
            self.streak = stats.streak
            self.totalSolved = stats.totalSolved
            self.activityHistory = stats.activityHistory
        }
    }
    
    private func createDefaultData() {
        groups.removeAll()
        addNewGroup(name: "All Cards")
        addNewGroup(name: "Favourites")
        addNewGroup(name: "Animals")
        
        let allCards = getGroup(by: "All Cards")!
        let favourites = getGroup(by: "Favourites")!
        let animals = getGroup(by: "Animals")!
        
        let card1 = Card(origin: "apple", translate: "яблоко")
        let card2 = Card(origin: "thunder", translate: "гром")
        let card3 = Card(origin: "dog", translate: "собака")
        let card4 = Card(origin: "milk", translate: "молоко")
        let card5 = Card(origin: "cat", translate: "кошка")
        let card6 = Card(origin: "snake", translate: "змея")
        
        allCards.addCard(card: card1)
        allCards.addCard(card: card2)
        allCards.addCard(card: card3)
        allCards.addCard(card: card4)
        allCards.addCard(card: card5)
        allCards.addCard(card: card6)
        
        favourites.addCard(card: card1)
        favourites.addCard(card: card2)
        
        animals.addCard(card: card3)
        animals.addCard(card: card5)
        animals.addCard(card: card6)
        
        card1.addNewGroup(groupName: "Favourites")
        card2.addNewGroup(groupName: "Favourites")
        card3.addNewGroup(groupName: "Animals")
        card5.addNewGroup(groupName: "Animals")
        card6.addNewGroup(groupName: "Animals")
    }
    
    // MARK: - Existing Methods
    func addNewGroup(name: String) {
        groups.append(CardsGroup(name: name, cards: Cards(cards: [])))
        saveToFile()
    }
    
    func getGroup(by name: String) -> Cards? {
        groups.first { $0.name == name }?.cards
    }
    
    func addCardToGroup(card: Card, groupName: String) {
        if let index = groups.firstIndex(where: { $0.name == groupName }) {
            groups[index].cards.addCard(card: card)
            card.addNewGroup(groupName: groupName)
            saveToFile()
        }
    }
    
    func removeCardFromGroup(card: Card, groupName: String) {
        if let index = groups.firstIndex(where: { $0.name == groupName }) {
            groups[index].cards.removeCard(card)
            card.removeGroup(groupName: groupName)
            saveToFile()
        }
    }
    
    func toggleCardFromFavourite(card: Card) {
        if let favourites = getGroup(by: "Favourites"),
           favourites.cardsArr.contains(where: { $0.id == card.id }) {
            removeCardFromGroup(card: card, groupName: "Favourites")
        } else {
            addCardToGroup(card: card, groupName: "Favourites")
        }
    }
    
    func deleteCard(_ card: Card) {
        for group in groups {
            group.cards.removeCard(card)
        }
        saveToFile()
    }
    
    func deleteGroup(_ group: CardsGroup) {
        groups.removeAll { $0.id == group.id }
        for card in group.cards.cardsArr {
            card.removeGroup(groupName: group.name)
        }
        saveToFile()
    }
    
    func renameGroup(_ group: CardsGroup, to newName: String) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            let oldName = groups[index].name
            groups[index].name = newName
            for card in groups[index].cards.cardsArr {
                if let groupIndex = card.groups.firstIndex(of: oldName) {
                    card.groups[groupIndex] = newName
                }
            }
            saveToFile()
        }
    }
    
    // MARK: - Init
    init() {
        loadFromFile()
    }
}
