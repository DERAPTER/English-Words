//
//  ThemeManagerTests.swift
//  English Words
//
//  Created by Егор Халиков on 03.04.2026.
//

import XCTest
@testable import English_Words

final class ThemeManagerTests: XCTestCase {
    
    var themeManager: ThemeManager!
    
    override func setUp() {
        super.setUp()
        themeManager = ThemeManager.shared
    }
    
    override func tearDown() {
        themeManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInitialTheme() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "beige"
        XCTAssertEqual(themeManager.currentTheme.rawValue, savedTheme)
    }
    
    // MARK: - Set Theme Tests
    func testSetGreenTheme() {
        themeManager.setTheme(.green)
        XCTAssertEqual(themeManager.currentTheme, .green)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "selectedTheme"), "green")
    }
    
    func testSetBeigeTheme() {
        themeManager.setTheme(.beige)
        XCTAssertEqual(themeManager.currentTheme, .beige)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "selectedTheme"), "beige")
    }
    
    func testSetBlueTheme() {
        themeManager.setTheme(.blue)
        XCTAssertEqual(themeManager.currentTheme, .blue)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "selectedTheme"), "blue")
    }
    func testSetPinkTheme() {
        themeManager.setTheme(.pink)
        XCTAssertEqual(themeManager.currentTheme, .pink)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "selectedTheme"), "pink")
    }
    
    // MARK: - Colors Tests
    func testThemeColorsNotNil() {
        let colors = themeManager.colors
        XCTAssertNotNil(colors.background)
        XCTAssertNotNil(colors.cardBackground)
        XCTAssertNotNil(colors.textPrimary)
        XCTAssertNotNil(colors.textSecondary)
        XCTAssertNotNil(colors.accent)
        XCTAssertNotNil(colors.stroke)
        XCTAssertNotNil(colors.correct)
        XCTAssertNotNil(colors.wrong)
    }
    
    func testDifferentThemesDifferentColors() {
        themeManager.setTheme(.beige)
        let beigeColors = themeManager.colors
        
        themeManager.setTheme(.green)
        let greenColors = themeManager.colors
        
        let beigeAccent = beigeColors.accent
        let greenAccent = greenColors.accent
        
        XCTAssertNotEqual(beigeAccent, greenAccent)
    }
}
