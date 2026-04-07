//
//  CardsTests.swift
//  English Words
//
//  Created by Егор Халиков on 03.04.2026.
//

import XCTest
@testable import English_Words

final class CardsTests: XCTestCase {
    
    var cards: Cards!
    var card1: Card!
    var card2: Card!
    var card3: Card!
    
    override func setUp() {
        super.setUp()
        card1 = Card(origin: "apple", translate: "яблоко")
        card2 = Card(origin: "dog", translate: "собака")
        card3 = Card(origin: "cat", translate: "кошка")
        cards = Cards(cards: [card1, card2, card3])
    }
    
    override func tearDown() {
        cards = nil
        card1 = nil
        card2 = nil
        card3 = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInicialization() {
        XCTAssertEqual(cards.cardsArr.count, 3)
        XCTAssertEqual(cards.unsolved.count, 3)
        XCTAssertTrue(cards.success.isEmpty)
        XCTAssertTrue(cards.fail.isEmpty)
        XCTAssertEqual(cards.curMaxIndexPublic, 3)
    }
    
    // MARK: - Progress Fraction Tests
    func testProgressFraction() {
        XCTAssertEqual(cards.progressFraction, 0)
        
        cards.solveSuccess(card: card1)
        XCTAssertEqual(cards.progressFraction, 1.0/3.0)
        
        cards.solveSuccess(card: card2)
        XCTAssertEqual(cards.progressFraction, 2.0/3.0)
    }
    
    // MARK: - Solve Tests
    func testSolveSuccess() {
        cards.solveSuccess(card: card1)
        XCTAssertEqual(cards.success.count, 1)
        XCTAssertEqual(cards.unsolved.count, 2)
        XCTAssertEqual(card1.correctCount, 1)
    }
    
    func testSolveFail() {
        cards.solveFail(card: card1)
        XCTAssertEqual(cards.fail.count, 1)
        XCTAssertEqual(cards.unsolved.count, 2)
        XCTAssertEqual(card1.wrongCount, 1)
    }
    
    // MARK: - Restart Tests
    func testRestartSolve() {
        cards.solveSuccess(card: card1)
        cards.solveFail(card: card2)
        cards.restartSolve()
        
        XCTAssertEqual(cards.unsolved.count, 3)
        XCTAssertTrue(cards.success.isEmpty)
        XCTAssertTrue(cards.fail.isEmpty)
    }
    
    func testRestartSolveWithMistakes() {
        cards.solveSuccess(card: card1)
        cards.solveFail(card: card2)
        cards.restartSolveWithMistakes()
        
        XCTAssertEqual(cards.unsolved.count, 1)
        XCTAssertTrue(cards.success.isEmpty)
        XCTAssertTrue(cards.fail.isEmpty)
    }
    
    // MARK: - Check State Tests
    func testCheckCurrentStateSolving() {
        XCTAssertEqual(cards.checkCurrentState(), .solving)
    }
    
    func testCheckCurrentStateFullRestart() {
        cards.solveSuccess(card: card1)
        cards.solveSuccess(card: card2)
        cards.solveSuccess(card: card3)
        XCTAssertEqual(cards.checkCurrentState(), .fullRestart)
    }
    
    func testCheckCurrentStateMistakesRestart() {
        cards.solveFail(card: card1)
        cards.solveFail(card: card2)
        cards.solveSuccess(card: card3)
        XCTAssertEqual(cards.checkCurrentState(), .mistakesRestart)
    }
    
    // MARK: - Add/Remove Card Tests
    func testAddCard() {
        let newCard = Card(origin: "bird", translate: "птица")
        cards.addCard(card: newCard)
        XCTAssertEqual(cards.cardsArr.count, 4)
    }
    
    func testRemoveCard() {
        cards.removeCard(card1)
        XCTAssertEqual(cards.cardsArr.count, 2)
        XCTAssertFalse(cards.cardsArr.contains { $0.id == card1.id})
    }
    
    // MARK: - Current Card Tests
    func testCurCard() {
        let curCard = cards.curCard
        XCTAssertNotNil(curCard)
        XCTAssertTrue(cards.cardsArr.contains { $0.id == curCard?.id })
    }
    
    // MARK: - Has Unfinished Session Tests
    func testHasUnfinishedSession() {
        XCTAssertFalse(cards.hasUnfinishedSession)
        
        cards.solveSuccess(card: card1)
        
        XCTAssertTrue(cards.hasUnfinishedSession)
        
        cards.solveSuccess(card: card2)
        cards.solveSuccess(card: card3)
        
        XCTAssertFalse(cards.hasUnfinishedSession)
    }
    
    // MARK: - Codable Tests
    func testCodable() throws {
        cards.solveSuccess(card: card1)
        cards.solveFail(card: card2)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(cards)
        
        let decoder = JSONDecoder()
        let decodedCards = try decoder.decode(Cards.self, from: data)
        
        XCTAssertEqual(decodedCards.cardsArr.count, cards.cardsArr.count)
        XCTAssertEqual(decodedCards.resultOfAllTime, cards.resultOfAllTime)
        XCTAssertEqual(decodedCards.countOfAttemps, cards.countOfAttemps)
    }
}
