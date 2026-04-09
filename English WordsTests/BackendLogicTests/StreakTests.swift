//
//  StreakTests.swift
//  English WordsTests
//
//  Created by Егор Халиков on 10.04.2026.
//

import XCTest
@testable import English_Words

final class StreakTests: XCTestCase {
    
    var cardsManager: CardsManager!
    var calendar: Calendar!
    
    override func setUp() {
        super.setUp()
        // Очищаем UserDefaults перед каждым тестом
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }
        cardsManager = CardsManager()
        calendar = Calendar.current
    }
    
    override func tearDown() {
        cardsManager = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func setDate(_ date: Date) {
        cardsManager.setTestCurrentDate(date)
    }
    
    private func completeDailyGoal(on date: Date) {
        setDate(date)
        for _ in 0..<20 {
            cardsManager.recordSolvedCard()
        }
    }
    
    private func partialDailyGoal(on date: Date, count: Int) {
        setDate(date)
        for _ in 0..<count {
            cardsManager.recordSolvedCard()
        }
    }
    
    private func simulateDay(_ date: Date, goalCompleted: Bool) {
        setDate(date)
        if goalCompleted {
            for _ in 0..<20 {
                cardsManager.recordSolvedCard()
            }
        } else {
            for _ in 0..<10 {
                cardsManager.recordSolvedCard()
            }
        }
    }
    
    // MARK: - Basic Streak Tests
    
    func testStreakStartsAtZero() {
        XCTAssertEqual(cardsManager.streak, 0)
    }
    
    func testStreakBecomesOneAfterFirstGoal() {
        let day1 = Date()
        completeDailyGoal(on: day1)
        XCTAssertEqual(cardsManager.streak, 1)
    }
    
    func testStreakIncreasesToTwoAfterSecondDay() {
        let day1 = calendar.date(byAdding: .day, value: -1, to: Date())!
        let day2 = Date()
        
        completeDailyGoal(on: day1)
        XCTAssertEqual(cardsManager.streak, 1)
        
        completeDailyGoal(on: day2)
        XCTAssertEqual(cardsManager.streak, 2)
    }
    
    // MARK: - Streak Reset Tests
    
    func testStreakResetsAfterMissedDay() {
        let day1 = calendar.date(byAdding: .day, value: -2, to: Date())!
        let day3 = Date()
        
        completeDailyGoal(on: day1)
        XCTAssertEqual(cardsManager.streak, 1)
        
        // День 2 пропущен (не вызываем recordSolvedCard)
        
        completeDailyGoal(on: day3)
        XCTAssertEqual(cardsManager.streak, 1)
    }
    
    func testStreakDoesNotIncreaseWithoutGoalCompletion() {
        let day1 = calendar.date(byAdding: .day, value: -1, to: Date())!
        let day2 = Date()
        
        completeDailyGoal(on: day1)
        XCTAssertEqual(cardsManager.streak, 1)
        
        // День 2: только 10 карточек
        partialDailyGoal(on: day2, count: 10)
        XCTAssertEqual(cardsManager.streak, 1)
        
        // Достигаем цель в тот же день
        partialDailyGoal(on: day2, count: 10)
        XCTAssertEqual(cardsManager.streak, 2)
    }
    
    // MARK: - Consecutive Days Tests
    
    func testStreakForMultipleConsecutiveDays() {
        let day1 = calendar.date(byAdding: .day, value: -4, to: Date())!
        let day2 = calendar.date(byAdding: .day, value: -3, to: Date())!
        let day3 = calendar.date(byAdding: .day, value: -2, to: Date())!
        let day4 = calendar.date(byAdding: .day, value: -1, to: Date())!
        let day5 = Date()
        
        completeDailyGoal(on: day1)
        completeDailyGoal(on: day2)
        completeDailyGoal(on: day3)
        completeDailyGoal(on: day4)
        completeDailyGoal(on: day5)
        
        XCTAssertEqual(cardsManager.streak, 5)
    }
    
    // MARK: - Edge Cases
    
    func testStreakWithExactGoalCompletion() {
        let day1 = calendar.date(byAdding: .day, value: -1, to: Date())!
        let day2 = Date()
        
        completeDailyGoal(on: day1)
        XCTAssertEqual(cardsManager.streak, 1)
        
        // 19 карточек
        partialDailyGoal(on: day2, count: 19)
        XCTAssertEqual(cardsManager.streak, 1)
        
        // 20-я карточка
        cardsManager.recordSolvedCard()
        XCTAssertEqual(cardsManager.streak, 2)
    }
    
    func testStreakWithOverGoalCompletion() {
        let day1 = calendar.date(byAdding: .day, value: -1, to: Date())!
        let day2 = Date()
        
        // 25 карточек (перевыполнение)
        setDate(day1)
        for _ in 0..<25 {
            cardsManager.recordSolvedCard()
        }
        XCTAssertEqual(cardsManager.streak, 1)
        
        // 30 карточек на следующий день
        setDate(day2)
        for _ in 0..<30 {
            cardsManager.recordSolvedCard()
        }
        XCTAssertEqual(cardsManager.streak, 2)
    }
    
    // MARK: - Activity History Tests
    
    func testActivityHistoryOnlyMarksDaysWithGoalCompleted() {
        let day = Date()
        
        partialDailyGoal(on: day, count: 15)
        let dayString = cardsManager.formatDate(day)
        XCTAssertFalse(cardsManager.activityHistory[dayString] == true)
        
        partialDailyGoal(on: day, count: 5)
        XCTAssertTrue(cardsManager.activityHistory[dayString] == true)
    }
    
    func testActivityHistoryForMultipleDays() {
        let day1 = calendar.date(byAdding: .day, value: -2, to: Date())!
        let day2 = calendar.date(byAdding: .day, value: -1, to: Date())!
        let day3 = Date()
        
        simulateDay(day1, goalCompleted: true)
        simulateDay(day2, goalCompleted: false)
        simulateDay(day3, goalCompleted: true)
        
        let day1String = cardsManager.formatDate(day1)
        let day2String = cardsManager.formatDate(day2)
        let day3String = cardsManager.formatDate(day3)
        
        XCTAssertTrue(cardsManager.activityHistory[day1String] == true)
        XCTAssertFalse(cardsManager.activityHistory[day2String] == true)
        XCTAssertTrue(cardsManager.activityHistory[day3String] == true)
    }
    
    // MARK: - Performance Tests
    
    func testStreakPerformance() {
        measure {
            let startDate = calendar.date(byAdding: .day, value: -30, to: Date())!
            
            for dayOffset in 0..<30 {
                let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
                completeDailyGoal(on: date)
            }
            
            XCTAssertEqual(cardsManager.streak, 30)
        }
    }
    
    // MARK: - Long Streak Tests
    
    func testLongStreakPreservation() {
        let startDate = calendar.date(byAdding: .day, value: -30, to: Date())!
        
        for dayOffset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
            completeDailyGoal(on: date)
        }
        
        XCTAssertEqual(cardsManager.streak, 30)
        
        // Проверяем, что после перезагрузки менеджера серия сохранилась
        let newManager = CardsManager()
        XCTAssertEqual(newManager.streak, 30)
    }
    
    // MARK: - Edge Case: Same Day Multiple Goal Completions
    
    func testStreakDoesNotIncreaseMultipleTimesInSameDay() {
        let day = Date()
        
        completeDailyGoal(on: day)
        XCTAssertEqual(cardsManager.streak, 1)
        
        // Ещё 20 карточек в тот же день
        for _ in 0..<20 {
            cardsManager.recordSolvedCard()
        }
        
        // Серия не должна увеличиться второй раз
        XCTAssertEqual(cardsManager.streak, 1)
    }
    
    // MARK: - Complex Scenario
    
    func testComplexStreakScenario() {
        let day1 = calendar.date(byAdding: .day, value: -6, to: Date())!
        let day2 = calendar.date(byAdding: .day, value: -5, to: Date())!
        let day3 = calendar.date(byAdding: .day, value: -4, to: Date())!
        let day4 = calendar.date(byAdding: .day, value: -3, to: Date())!
        let day5 = calendar.date(byAdding: .day, value: -2, to: Date())!
        let day6 = calendar.date(byAdding: .day, value: -1, to: Date())!
        let day7 = Date()
        
        // День 1: цель достигнута → серия = 1
        simulateDay(day1, goalCompleted: true)
        XCTAssertEqual(cardsManager.streak, 1)
        
        // День 2: цель НЕ достигнута → серия = 1
        simulateDay(day2, goalCompleted: false)
        XCTAssertEqual(cardsManager.streak, 1)
        
        // День 3: цель достигнута → серия = 1 (сброс из-за пропуска)
        simulateDay(day3, goalCompleted: true)
        XCTAssertEqual(cardsManager.streak, 1)
        
        // День 4: цель достигнута → серия = 2
        simulateDay(day4, goalCompleted: true)
        XCTAssertEqual(cardsManager.streak, 2)
        
        // День 5: цель НЕ достигнута → серия = 2
        simulateDay(day5, goalCompleted: false)
        XCTAssertEqual(cardsManager.streak, 2)
        
        // День 6: цель достигнута → серия = 1 (сброс)
        simulateDay(day6, goalCompleted: true)
        XCTAssertEqual(cardsManager.streak, 1)
        
        // День 7: цель достигнута → серия = 2
        simulateDay(day7, goalCompleted: true)
        XCTAssertEqual(cardsManager.streak, 2)
    }
    
    // MARK: - Streak Persistence After App Restart
    
    func testStreakPersistsAfterAppRestart() {
        let day1 = calendar.date(byAdding: .day, value: -1, to: Date())!
        let day2 = Date()
        
        completeDailyGoal(on: day1)
        completeDailyGoal(on: day2)
        
        XCTAssertEqual(cardsManager.streak, 2)
        
        // Симулируем перезапуск приложения
        let newManager = CardsManager()
        XCTAssertEqual(newManager.streak, 2)
    }
    
    // MARK: - One Day Streak
    
    func testOneDayStreak() {
        let day = Date()
        completeDailyGoal(on: day)
        XCTAssertEqual(cardsManager.streak, 1)
    }
    
    // MARK: - No Streak After Partial Completion
    
    func testNoStreakAfterPartialCompletion() {
        let day = Date()
        partialDailyGoal(on: day, count: 19)
        XCTAssertEqual(cardsManager.streak, 0)
    }
}
