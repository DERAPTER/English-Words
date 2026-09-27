//
//  SettingsViewModel.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - State
    
    private(set) var storageSize: String = "…"
    private(set) var errorMessage: String?
    
    var showResetStatsAlert = false
    var showDeleteAllAlert = false
    var showReleaseNotesSheet = false
    var showLanguageChangeAlert = false
    
    var pendingLanguage: AppLanguage?
    
    // MARK: - Dependencies
    
    private let cardRepository: CardRepository
    private let groupRepository: GroupRepository
    private let statsRepository: StatsRepository
    private let solveSessionStore: SolveSessionStore
    
    init(
        cardRepository: CardRepository,
        groupRepository: GroupRepository,
        statsRepository: StatsRepository,
        solveSessionStore: SolveSessionStore
    ) {
        self.cardRepository = cardRepository
        self.groupRepository = groupRepository
        self.statsRepository = statsRepository
        self.solveSessionStore = solveSessionStore
    }
    
    // MARK: - Storage size
    
    func updateStorageSize() {
        storageSize = StorageSizeCalculator.calculate()
    }
    
    // MARK: - Reset stats
    
    func resetStatistics() {
        do {
            try statsRepository.resetAllStats()
            solveSessionStore.clearAll()
            updateStorageSize()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Delete all data
    
    func deleteAllData() {
        do {
            // Удаляем все карточки
            let cards = try cardRepository.fetchAll()
            for card in cards {
                try cardRepository.delete(card)
            }
            
            // Удаляем все пользовательские группы
            let groups = try groupRepository.fetchUserGroups()
            for group in groups {
                try groupRepository.delete(group)
            }
            
            // Сбрасываем статистику и сессии
            try statsRepository.resetAllStats()
            solveSessionStore.clearAll()
            
            // Сбрасываем dailyGoal к дефолту
            try statsRepository.updateDailyGoal(20)
            
            updateStorageSize()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Language
    
    func requestLanguageChange(to language: AppLanguage) {
        pendingLanguage = language
        showLanguageChangeAlert = true
    }
    
    func confirmLanguageChange() {
        guard let language = pendingLanguage else { return }
        LanguageManager.shared.setLanguage(language)
        pendingLanguage = nil
    }
    
    func cancelLanguageChange() {
        pendingLanguage = nil
    }
}
