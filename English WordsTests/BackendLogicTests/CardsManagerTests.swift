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
        let allCards = cardsManager.getGroup(by: "All Cards")!
        let cardToRemove = allCards.cardsArr.first!
        
        cardsManager.removeCardFromGroup(card: cardToRemove, groupName: "All Cards")
        
        let updatedAllCards = cardsManager.getGroup(by: "All Cards")
        XCTAssertFalse(updatedAllCards?.cardsArr.count == allCards.cardsArr.count)
        XCTAssertFalse(updatedAllCards?.cardsArr.contains { $0.id == cardToRemove.id } ?? false)
    }
    
    // MARK: - Favourite Tests
    func testToggleFavourite() {
        let allCards = cardsManager.getGroup(by: "All Cards")!
        let card = allCards.cardsArr.first!
        
        cardsManager.toggleCardFromFavourite(card: card)
        let favourites = cardsManager.getGroup(by: "Favourites")!
        XCTAssertTrue(favourites.cardsArr.contains {$0.id == card.id})
        XCTAssertTrue(card.isFavourite)
        
        cardsManager.toggleCardFromFavourite(card: card)
        let updatedFavourites = cardsManager.getGroup(by: "Favourites")!
        XCTAssertFalse(updatedFavourites.cardsArr.contains {$0.id == card.id})
        XCTAssertFalse(card.isFavourite)
    }
    
    // MARK: - Statistics Tests
    func testTotalCardsCount() {
        XCTAssertEqual(cardsManager.totalCardsCount, 6)
        
        let newCard = Card(origin: "test", translate: "тест")
        cardsManager.addCardToGroup(card: newCard, groupName: "All Cards")
        XCTAssertEqual(cardsManager.totalCardsCount, 7)
        
        cardsManager.deleteCard(newCard)
        XCTAssertEqual(cardsManager.totalCardsCount, 6)
    }
    
    // MARK: - Daily Tests
    func testUpdateDailyGoal() {
        cardsManager.updateDailyGoal(10)
        XCTAssertEqual(cardsManager.dailyGoal, 10)
    }
    
    func testDailyGoalClamping() {
        cardsManager.updateDailyGoal(0)
        XCTAssertEqual(cardsManager.dailyGoal, 1)
        
        cardsManager.updateDailyGoal(200)
        XCTAssertEqual(cardsManager.dailyGoal, 100)
    }
    
    // MARK: - System Group Tests
    func testIsSystemGroup() {
        let allCards = cardsManager.groups.first { $0.name == "All Cards" }
        let favourites = cardsManager.groups.first { $0.name == "Favourites" }
        let animals = cardsManager.groups.first { $0.name == "Animals" }
        
        XCTAssertTrue(cardsManager.isSystemGroup(allCards!))
        XCTAssertTrue(cardsManager.isSystemGroup(favourites!))
        XCTAssertFalse(cardsManager.isSystemGroup(animals!))
    }
}
