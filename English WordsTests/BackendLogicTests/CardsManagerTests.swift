//
//  CardsManagerTests.swift
//  English Words
//
//  Created by Егор Халиков on 03.04.2026.
//

import XCTest
@testable import English_Words

final class CardsManagerTests: XCTestCase {
    
    var cardsManager: CardsManager!
    
    override func setUp() {
        super.setUp()
        cardsManager = CardsManager()
    }
    
    override func tearDown() {
        cardsManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInitialGroups() {
        XCTAssertEqual(cardsManager.groups.count, 3)
        XCTAssertTrue(cardsManager.groups.contains { $0.name == "All Cards" })
        XCTAssertTrue(cardsManager.groups.contains { $0.name == "Favourites" })
        XCTAssertFalse(cardsManager.groups.contains { $0.name == "Animals" })
    }
    
    // MARK: - Add Group Tests
    func testAddNewGroup() {
        cardsManager.addNewGroup(name: "Test Group")
        XCTAssertEqual(cardsManager.groups.count, 4)
        XCTAssertTrue(cardsManager.groups.contains { $0.name == "Test Group" })
    }
    
    // MARK: - Delete Group Tests
    func testDeleteGroup() {
        let groupToDelete = cardsManager.groups.first {$0.name == "Animals"}
        XCTAssertNotNil(groupToDelete)
        
        cardsManager.deleteGroup(groupToDelete!)
        XCTAssertEqual(cardsManager.groups.count, 2)
        XCTAssertFalse(cardsManager.groups.contains {$0.name == "Animals"} )
    }
    
    // MARK: - Rename Group Tests
    func testRenameGroup() {
        let animalsGroup = cardsManager.groups.first(where: {$0.name == "Animals"} )
        XCTAssertNotNil(animalsGroup)
        
        cardsManager.renameGroup(animalsGroup!, to: "Pets")
        
        let renamedGroup = cardsManager.groups.first {$0.id == animalsGroup?.id}
        XCTAssertEqual(renamedGroup?.name, "Pets")
    }
    
    // MARK: - Add Card Tests
    func testAddCardToGroup() {
        let newCard = Card(origin: "test", translate: "тест")
        cardsManager.addCardToGroup(card: newCard, groupName: "All Cards")
        
        let allCards = cardsManager.getGroup(by: "All Cards")
        XCTAssertTrue(allCards?.cardsArr.contains {$0.id == newCard.id } ?? false)
    }
    
    // MARK: - Remove Card Tests
    func testRemoveCardFromGroup() {
        
    }
    
}
