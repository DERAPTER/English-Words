//
//  SRSOverviewViewModel.swift
//  English Words
//
//  Created by Егор Халиков on 07.10.2026.
//

import Foundation

@MainActor
@Observable
final class SRSOverviewViewModel {
    
    private(set) var overview: SRSOverview?
    private(set) var errorMessage: String?
    
    private let cardRepository: CardRepository
    
    init(cardRepository: CardRepository) {
        self.cardRepository = cardRepository
    }
    
    // MARK: - Loading
    
    func load() {
        let limit = UserDefaults.standard.integer(forKey: "srsNewCardsPerDay")
        let effectiveLimit = limit > 0 ? limit : 20
        do {
            overview = try cardRepository.srsOverview(
                on: .now,
                newCardsLimit: effectiveLimit
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Date formatting
    
    /// «Завтра», «В среду», «15 октября» — в зависимости от близости даты.
    func formattedNextDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = LanguageManager.shared.currentLanguage.locale
        
        if calendar.isDateInTomorrow(date) {
            return "srs_overview_tomorrow".localized()
        }
        
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: .now),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        
        if days <= 6 {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date).capitalized
        }
        
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
}
