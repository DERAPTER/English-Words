//
//  Cards.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

class Cards: ObservableObject, Codable {
    
    let id = UUID()
    var hasAppeared: Bool = false
    
    @Published var cardsArr: [Card] = []
    @Published var unsolved: [Card] = []
    
    var progressFraction: Double {
        let totalRound = unsolved.count + success.count + fail.count
        guard totalRound > 0 else { return 0 }
        return Double(success.count) / Double(totalRound)
    }
    
    // для просмотра прогресса
    var resultOfAllTime: Double = 0
    var countOfAttemps = 0
    
    // MARK: - Session State (для сохранения прогресса)
    var hasUnfinishedSession: Bool {
        // Сессия считается незавершённой, если:
        // 1. Есть решённые карточки (success или fail не пустые)
        // 2. И при этом ещё остались нерешённые карточки (unsolved не пустой)
        // 3. И общее количество решённых + нерешённых равно общему количеству карточек (избегаем дублирования)
        let hasSolvedCards = !success.isEmpty || !fail.isEmpty
        let hasUnsolvedCards = !unsolved.isEmpty
        let totalMatches = (success.count + fail.count + unsolved.count) == cardsArr.count
        
        return hasSolvedCards && hasUnsolvedCards && totalMatches
    }
    
    var isSessionCompleted: Bool {
        // Сессия завершена, если нет нерешённых карточек (unsolved пуст)
        // И при этом были попытки (или success + fail == cardsArr.count)
        return unsolved.isEmpty && (success.count + fail.count == cardsArr.count)
    }
    
    var totalSolvedInSession: Int {
        success.count + fail.count
    }
    
    func updateResultOfAllTime(newResult: Double) {
        countOfAttemps += 1
        resultOfAllTime *= Double(countOfAttemps-1)
        resultOfAllTime += newResult
        resultOfAllTime = resultOfAllTime / Double(countOfAttemps)
    }
    
    func resetStats() {
        resultOfAllTime = 0
        countOfAttemps = 0
    }
    
    private var unsolvedShuffled: [Card] = []
    @Published var success: [Card] = []
    @Published var fail: [Card] = []
    private var curIndex = 0
    
    var curIndexPublic: Int {
        // Возвращаем количество уже решённых карточек + 1
        return success.count + fail.count + 1
    }
    
    @Published var curMaxIndexPublic: Int = 0
    
    var curCard: Card? {
        guard !unsolved.isEmpty else { return nil }
        if unsolvedShuffled.isEmpty {
            unsolvedShuffled = unsolved.shuffled()
        }
        // Убеждаемся, что curIndex не выходит за пределы
        guard curIndex < unsolvedShuffled.count else {
            resetUnsolvedShuffled()
            return unsolvedShuffled.first
        }
        return unsolvedShuffled[curIndex]
    }
    
    init(cards: [Card]) {
        self.cardsArr = cards
        restartSolve()
        curMaxIndexPublic = cardsArr.count
    }
    
    func moveToNext() {
        curIndex += 1
        if curIndex >= unsolvedShuffled.count {
            unsolvedShuffled = unsolved.shuffled()
            curIndex = 0
        }
        // Обновляем UI
        objectWillChange.send()
    }
    
    func addCard(card: Card) {
        cardsArr.append(card)
    }
    
    func removeCard(_ card: Card) {
        cardsArr.removeAll { $0.id == card.id }
        success.removeAll { $0.id == card.id }
        fail.removeAll { $0.id == card.id }
        unsolved.removeAll { $0.id == card.id }
        resetUnsolvedShuffled()
    }
    
    func checkCurrentState() -> SolvingCardCases {
        if !unsolved.isEmpty { return .solving }
        if unsolved.isEmpty && fail.isEmpty { return .fullRestart }
        if unsolved.isEmpty && !fail.isEmpty {
            // Если есть только ошибки (fail) и нет unsolved, значит все карточки были показаны
            // и нужно предложить повторить ошибки
            return .mistakesRestart
        }
        return .error
    }
    
    func restartSolve() {
        if !success.isEmpty || !fail.isEmpty {
            updateResultOfAllTime(newResult: progressFraction)
        }
        unsolved = cardsArr
        success = []
        fail = []
        curMaxIndexPublic = cardsArr.count
        resetUnsolvedShuffled()
        objectWillChange.send()
    }
    
    func continueSession() {
        // Убеждаемся, что сессия действительно может быть продолжена
        guard hasUnfinishedSession else { return }
        
        resetUnsolvedShuffled()
        curMaxIndexPublic = cardsArr.count
        objectWillChange.send()
    }
    
    func restartSolveWithMistakes() {
        if !success.isEmpty || !fail.isEmpty {
            if unsolved.count + success.count + fail.count == cardsArr.count {
                updateResultOfAllTime(newResult: progressFraction)
            }
        }
        unsolved = fail
        curMaxIndexPublic = fail.count
        success = []
        fail = []
        resetUnsolvedShuffled()
        objectWillChange.send()
    }
    
    func resetUnsolvedShuffled() {
        unsolvedShuffled = unsolved.shuffled()
        curIndex = 0
    }
    
    func solveSuccess(card: Card) {
        card.correctCount += 1
        
        guard let index = unsolved.firstIndex(where: { $0.id == card.id }) else { return }
        let successedCard = unsolved.remove(at: index)
        success.append(successedCard)
        moveToNext()
        objectWillChange.send()
    }
    
    func solveFail(card: Card) {
        card.wrongCount += 1
        
        guard let index = unsolved.firstIndex(where: { $0.id == card.id }) else { return }
        let failedCard = unsolved.remove(at: index)
        fail.append(failedCard)
        moveToNext()
        objectWillChange.send()
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case cardsArr, resultOfAllTime, countOfAttemps, successIds, failIds, unsolvedIds
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cardsArr = try container.decode([Card].self, forKey: .cardsArr)
        resultOfAllTime = try container.decode(Double.self, forKey: .resultOfAllTime)
        countOfAttemps = try container.decode(Int.self, forKey: .countOfAttemps)
        
        // Восстанавливаем сессию по ID карточек
        let successIds = try container.decode([UUID].self, forKey: .successIds)
        let failIds = try container.decode([UUID].self, forKey: .failIds)
        let unsolvedIds = try container.decode([UUID].self, forKey: .unsolvedIds)
        
        self.success = cardsArr.filter { successIds.contains($0.id) }
        self.fail = cardsArr.filter { failIds.contains($0.id) }
        self.unsolved = cardsArr.filter { unsolvedIds.contains($0.id) }
        
        curMaxIndexPublic = cardsArr.count
        resetUnsolvedShuffled()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cardsArr, forKey: .cardsArr)
        try container.encode(resultOfAllTime, forKey: .resultOfAllTime)
        try container.encode(countOfAttemps, forKey: .countOfAttemps)
        
        // Сохраняем только ID карточек для восстановления сессии
        try container.encode(success.map { $0.id }, forKey: .successIds)
        try container.encode(fail.map { $0.id }, forKey: .failIds)
        try container.encode(unsolved.map { $0.id }, forKey: .unsolvedIds)
    }
}
