//
//  CardTests.swift
//  English Words
//
//  Created by Егор Халиков on 03.04.2026.
//

import XCTest
@testable import English_Words

final class CardTests: XCTestCase {
    var card: Card!
    
    override func setUp() {
        super.setUp()
        card = Card(origin: "apple", translate: "яблоко")
    }
    
    override func tearDown() {
        card = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testCardInitialization() {
        XCTAssertEqual(card.originWord, "apple")
        XCTAssertEqual(card.translatedWord, "яблоко")
        XCTAssertNotNil(card.id)
        XCTAssertNotNil(card.dateAdded)
        XCTAssertEqual(card.correctCount, 0)
        XCTAssertEqual(card.wrongCount, 0)
        XCTAssertFalse(card.isFavourite)
    }
    
    // MARK: - Groups Tests
    func testAddNewGroup() {
        card.addNewGroup(groupName: "Fruits")
        XCTAssertTrue(card.groups.contains("Fruits"))
        XCTAssertEqual(card.groups.count, 1)
    }
    
    func testAddDuplicateGroup() {
        card.addNewGroup(groupName: "Fruits")
        card.addNewGroup(groupName: "Fruits")
        XCTAssertEqual(card.groups.count, 1)
    }
    
    func testRemoveGroup() {
        card.addNewGroup(groupName: "Fruits")
        card.removeGroup(groupName: "Fruits")
        XCTAssertFalse(card.groups.contains("Fruits"))
    }
    
    func testIsFavourite() {
        XCTAssertFalse(card.isFavourite)
        card.addNewGroup(groupName: "Favourites")
        XCTAssertTrue(card.isFavourite)
    }
    
    // MARK: - Equatable Tests
    func testEquatable() {
        let card2 = Card(origin: "apple", translate: "яблоко")
        XCTAssertEqual(card, card)
        XCTAssertNotEqual(card, card2)
    }
    
    // MARK: - Codable Tests
    func testCodable() throws {
        card.addNewGroup(groupName: "Fruits")
        card.correctCount = 5
        card.wrongCount = 2
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(card)
        
        let decoder = JSONDecoder()
        let decodedCard = try decoder.decode(Card.self, from: data)
        
        XCTAssertEqual(decodedCard.id, card.id)
        XCTAssertEqual(decodedCard.originWord, card.originWord)
        XCTAssertEqual(decodedCard.translatedWord, card.translatedWord)
        XCTAssertEqual(decodedCard.groups, card.groups)
        XCTAssertEqual(decodedCard.dateAdded, card.dateAdded)
        XCTAssertEqual(decodedCard.correctCount, card.correctCount)
        XCTAssertEqual(decodedCard.wrongCount, card.wrongCount)
    }
    
}
