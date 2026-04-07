//
//  LanguageManagerTests.swift
//  English Words
//
//  Created by Егор Халиков on 03.04.2026.
//

import XCTest
@testable import English_Words

final class LanguageManagerTests: XCTestCase {
    
    var languageManager: LanguageManager!
    
    override func setUp() {
        super.setUp()
        languageManager = LanguageManager.shared
    }
    
    override func tearDown() {
        languageManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInitialLanguage() {
        let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        XCTAssertEqual(languageManager.currentLanguage.rawValue, savedLanguage)
    }
    
    // MARK: - Set Language Tests
    func testSetEnglishLanguage() {
        languageManager.setLanguage(.english)
        XCTAssertEqual(languageManager.currentLanguage, .english)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "appLanguage"), "en")
    }
    
    func testSetRussianLanguage() {
        languageManager.setLanguage(.russian)
        XCTAssertEqual(languageManager.currentLanguage, .russian)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "appLanguage"), "ru")
    }
    
    // MARK: - Localized String Tests
    func testLocalizedString() {
        languageManager.setLanguage(.english)
        let englishString = "settings_title".localized()
        XCTAssertFalse(englishString.isEmpty)
        
        languageManager.setLanguage(.russian)
        let russianString = "settings_title".localized()
        XCTAssertFalse(russianString.isEmpty)
    }
}
