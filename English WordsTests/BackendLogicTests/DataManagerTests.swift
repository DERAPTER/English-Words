//
//  DataManagerTests.swift
//  English Words
//
//  Created by Егор Халиков on 03.04.2026.
//

import XCTest
@testable import English_Words

final class DataManagerTests: XCTestCase {
    
    var dataManager: DataManager!
    var testGroups: [CardsGroup]!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager.shared
        
        let cards = Cards(cards: [
            Card(origin: "test1", translate: "тест1"),
            Card(origin: "test2", translate: "тест2")
        ])
        
        testGroups = [CardsGroup(name: "Test Group", cards: cards)]
    }
    
    override func tearDown() {
        dataManager.clearAllData()
        testGroups = nil
        super.tearDown()
    }
    
    // MARK: - Save And Load Tests
    func testSaveAndLoadData() {
        dataManager.saveData(groups: testGroups)
        let loadedGroups = dataManager.loadData()
        
        XCTAssertNotNil(loadedGroups)
        XCTAssertEqual(loadedGroups?.count, testGroups.count)
        XCTAssertEqual(loadedGroups?.first?.name, testGroups.first?.name)
    }
    
    func testLoadDataWhenNoFile() {
        dataManager.clearAllData()
        let loadedGroups = dataManager.loadData()
        XCTAssertNil(loadedGroups)
    }
    
    // MARK: - Clear Data Tests
    func testClearAllData() {
        dataManager.saveData(groups: testGroups)
        dataManager.clearAllData()
        let loadedGroups = dataManager.loadData()
        XCTAssertNil(loadedGroups)
    }
    
    // Mark: - Statistics Tests
    func testSaveAndLoadStatistics() {
        let testHistory = ["2026-01-01": true, "2026-01-02": false]
        
        dataManager.saveStatistics(dailyGoal: 30, streak: 5, totalSolved: 100, activityHistory: testHistory)
        
        let stats = dataManager.loadStatistics()
        
        XCTAssertEqual(stats.dailyGoal, 30)
        XCTAssertEqual(stats.streak, 5)
        XCTAssertEqual(stats.totalSolved, 100)
        XCTAssertEqual(stats.activityHistory["2026-01-01"], true)
    }
    
    // MARK: - Storage Size Tests
    func testGetStorageSize() {
        dataManager.saveData(groups: testGroups)
        let size = dataManager.getStorageSize()
        XCTAssertNotEqual(size, "0 KB")
        XCTAssertNotEqual(size, "Ошибка")
    }
}
