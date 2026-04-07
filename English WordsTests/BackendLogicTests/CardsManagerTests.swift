//
//  CardsManagerTests.swift
//  English WordTests
//
//  Created by Егор Халиков on 02.04.2026.
//

import XCTest
@testable import English_Words

final class CardsManagerTests: XCTestCase {
    
    var cardsManager: CardsManager!
    
    override func setUp() {
        super.setUp()
        cardsManager = CardsManager()
        // Убеждаемся, что есть дефолтные данные
        if cardsManager.groups.isEmpty {
            cardsManager.addNewGroup(name: "All Cards")
            cardsManager.addNewGroup(name: "Favourites")
        }
    }
    
    override func tearDown() {
        cardsManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInitialGroups() {
        // Проверяем, что есть хотя бы системные группы
        XCTAssertTrue(cardsManager.groups.contains { $0.name == "All Cards" })
        XCTAssertTrue(cardsManager.groups.contains { $0.name == "Favourites" })
    }
    
    // MARK: - Add Group Tests
    func testAddNewGroup() {
        let initialCount = cardsManager.groups.count
        cardsManager.addNewGroup(name: "Test Group")
        XCTAssertEqual(cardsManager.groups.count, initialCount + 1)
        XCTAssertTrue(cardsManager.groups.contains { $0.name == "Test Group" })
    }
    
    // MARK: - Delete Group Tests
    func testDeleteGroup() {
        // Сначала создаём тестовую группу
        cardsManager.addNewGroup(name: "Test Delete Group")
        let initialCount = cardsManager.groups.count
        
        // Находим созданную группу
        guard let groupToDelete = cardsManager.groups.first(where: { $0.name == "Test Delete Group" }) else {
            XCTFail("Тестовая группа не найдена")
            return
        }
        
        cardsManager.deleteGroup(groupToDelete)
        
        // Проверяем, что группа удалена
        XCTAssertEqual(cardsManager.groups.count, initialCount - 1)
        XCTAssertFalse(cardsManager.groups.contains { $0.name == "Test Delete Group" })
    }
    
    // MARK: - Test Cannot Delete System Group
    func testCannotDeleteSystemGroup() {
        let initialCount = cardsManager.groups.count
        
        // Пытаемся удалить системную группу
        guard let allCardsGroup = cardsManager.groups.first(where: { $0.name == "All Cards" }) else {
            XCTFail("Группа All Cards не найдена")
            return
        }
        
        cardsManager.deleteGroup(allCardsGroup)
        
        // Системная группа не должна удалиться
        XCTAssertEqual(cardsManager.groups.count, initialCount)
        XCTAssertTrue(cardsManager.groups.contains { $0.name == "All Cards" })
    }
    
    // MARK: - Rename Group Tests
    func testRenameGroup() {
        // Создаём тестовую группу
        cardsManager.addNewGroup(name: "Test Rename Group")
        
        guard let testGroup = cardsManager.groups.first(where: { $0.name == "Test Rename Group" }) else {
            XCTFail("Тестовая группа не найдена")
            return
        }
        
        cardsManager.renameGroup(testGroup, to: "Renamed Group")
        
        let renamedGroup = cardsManager.groups.first { $0.id == testGroup.id }
        XCTAssertEqual(renamedGroup?.name, "Renamed Group")
    }
    
    // MARK: - Test Cannot Rename System Group
    func testCannotRenameSystemGroup() {
        guard let allCardsGroup = cardsManager.groups.first(where: { $0.name == "All Cards" }) else {
            XCTFail("Группа All Cards не найдена")
            return
        }
        
        let originalName = allCardsGroup.name
        cardsManager.renameGroup(allCardsGroup, to: "New Name")
        
        // Системная группа не должна переименоваться
        let unchangedGroup = cardsManager.groups.first { $0.id == allCardsGroup.id }
        XCTAssertEqual(unchangedGroup?.name, originalName)
    }
    
    // MARK: - Add Card Tests
    func testAddCardToGroup() {
        // Убеждаемся, что группа "All Cards" существует
        let allCardsGroup = cardsManager.getGroup(by: "All Cards")
        XCTAssertNotNil(allCardsGroup, "Группа All Cards не найдена")
        
        let initialCount = allCardsGroup?.cardsArr.count ?? 0
        let newCard = Card(origin: "test", translate: "тест")
        cardsManager.addCardToGroup(card: newCard, groupName: "All Cards")
        
        let updatedAllCards = cardsManager.getGroup(by: "All Cards")
        XCTAssertEqual(updatedAllCards?.cardsArr.count, initialCount + 1)
        XCTAssertTrue(updatedAllCards?.cardsArr.contains { $0.id == newCard.id } ?? false)
    }
    
    // MARK: - Remove Card Tests
    func testRemoveCardFromGroup() {
        // Сначала добавляем карточку
        let newCard = Card(origin: "test_remove", translate: "тест_удаления")
        cardsManager.addCardToGroup(card: newCard, groupName: "All Cards")
        
        let allCards = cardsManager.getGroup(by: "All Cards")!
        let initialCount = allCards.cardsArr.count
        
        cardsManager.removeCardFromGroup(card: newCard, groupName: "All Cards")
        
        let updatedAllCards = cardsManager.getGroup(by: "All Cards")!
        XCTAssertEqual(updatedAllCards.cardsArr.count, initialCount - 1)
        XCTAssertFalse(updatedAllCards.cardsArr.contains { $0.id == newCard.id })
    }
    
    // MARK: - Favourite Tests
    func testToggleFavourite() {
        // Создаём тестовую карточку
        let testCard = Card(origin: "favourite_test", translate: "тест_избранного")
        cardsManager.addCardToGroup(card: testCard, groupName: "All Cards")
        
        // Добавляем в избранное
        cardsManager.toggleCardFromFavourite(card: testCard)
        let favourites = cardsManager.getGroup(by: "Favourites")!
        XCTAssertTrue(favourites.cardsArr.contains { $0.id == testCard.id })
        
        // Удаляем из избранного
        cardsManager.toggleCardFromFavourite(card: testCard)
        let updatedFavourites = cardsManager.getGroup(by: "Favourites")!
        XCTAssertFalse(updatedFavourites.cardsArr.contains { $0.id == testCard.id })
    }
    
    // MARK: - Statistics Tests
    func testTotalCardsCount() {
        let allCards = cardsManager.getGroup(by: "All Cards")
        XCTAssertNotNil(allCards)
        
        let initialCount = allCards!.cardsArr.count
        
        // Добавляем карточку и проверяем увеличение счётчика
        let newCard = Card(origin: "new", translate: "новый")
        cardsManager.addCardToGroup(card: newCard, groupName: "All Cards")
        XCTAssertEqual(cardsManager.totalCardsCount, initialCount + 1)
        
        // Добавляем ещё одну карточку
        let newCard2 = Card(origin: "new2", translate: "новый2")
        cardsManager.addCardToGroup(card: newCard2, groupName: "All Cards")
        XCTAssertEqual(cardsManager.totalCardsCount, initialCount + 2)
    }
    
    func testFavouritesCount() {
        // Создаём тестовую карточку
        let testCard = Card(origin: "fav_count_test", translate: "тест_счётчика")
        cardsManager.addCardToGroup(card: testCard, groupName: "All Cards")
        
        let initialFavouritesCount = cardsManager.favouritesCount
        
        // Добавляем в избранное
        cardsManager.toggleCardFromFavourite(card: testCard)
        XCTAssertEqual(cardsManager.favouritesCount, initialFavouritesCount + 1)
        
        // Удаляем из избранного
        cardsManager.toggleCardFromFavourite(card: testCard)
        XCTAssertEqual(cardsManager.favouritesCount, initialFavouritesCount)
    }
    
    // MARK: - Daily Goal Tests
    func testUpdateDailyGoal() {
        cardsManager.updateDailyGoal(50)
        XCTAssertEqual(cardsManager.dailyGoal, 50)
    }
    
    func testDailyGoalClamping() {
        cardsManager.updateDailyGoal(0)
        XCTAssertEqual(cardsManager.dailyGoal, 1)
        
        cardsManager.updateDailyGoal(200)
        XCTAssertEqual(cardsManager.dailyGoal, 100)
    }
    
    // MARK: - System Group Tests
    func testIsSystemGroup() {
        let allCardsGroup = cardsManager.groups.first { $0.name == "All Cards" }
        let favouritesGroup = cardsManager.groups.first { $0.name == "Favourites" }
        
        XCTAssertNotNil(allCardsGroup)
        XCTAssertNotNil(favouritesGroup)
        
        XCTAssertTrue(cardsManager.isSystemGroup(allCardsGroup!))
        XCTAssertTrue(cardsManager.isSystemGroup(favouritesGroup!))
        
        // Создаём обычную группу и проверяем
        cardsManager.addNewGroup(name: "Regular Group")
        let regularGroup = cardsManager.groups.first { $0.name == "Regular Group" }
        XCTAssertNotNil(regularGroup)
        XCTAssertFalse(cardsManager.isSystemGroup(regularGroup!))
    }
}
