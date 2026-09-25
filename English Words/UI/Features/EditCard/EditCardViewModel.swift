//
//  EditCardViewModel.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation

@MainActor
@Observable
final class EditCardViewModel {
    
    // MARK: - Identity
    
    let card: Card
    
    // MARK: - Original state (для отслеживания изменений)
    
    private let originalOrigin: String
    private let originalTranslated: String
    private let originalGroupIDs: Set<UUID>
    
    // MARK: - Editable state
    
    var editedOrigin: String
    var editedTranslated: String
    
    private(set) var selectedGroups: [CardGroup] = []
    private(set) var availableGroups: [CardGroup] = []
    
    // MARK: - Alerts
    
    var showDeleteConfirmation = false
    var showDuplicateAlert = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let cardRepository: CardRepository
    private let groupRepository: GroupRepository
    
    init(
        card: Card,
        cardRepository: CardRepository,
        groupRepository: GroupRepository
    ) {
        self.card = card
        self.cardRepository = cardRepository
        self.groupRepository = groupRepository
        
        self.originalOrigin = card.originWord
        self.originalTranslated = card.translatedWord
        self.originalGroupIDs = Set(card.groups.map(\.id))
        
        self.editedOrigin = card.originWord
        self.editedTranslated = card.translatedWord
    }
    
    // MARK: - Derived
    
    var canSave: Bool {
        !editedOrigin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !editedTranslated.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var hasChanges: Bool {
        let trimmedOrigin = editedOrigin.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTranslated = editedTranslated.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentGroupIDs = Set(selectedGroups.map(\.id))
        
        return trimmedOrigin != originalOrigin ||
               trimmedTranslated != originalTranslated ||
               currentGroupIDs != originalGroupIDs
    }
    
    // MARK: - Lifecycle
    
    func onAppear() {
        loadGroups()
    }
    
    private func loadGroups() {
        do {
            let userGroups = try groupRepository.fetchUserGroups()
            let cardGroupIDs = Set(card.groups.map(\.id))
            
            selectedGroups = userGroups.filter { cardGroupIDs.contains($0.id) }
            availableGroups = userGroups.filter { !cardGroupIDs.contains($0.id) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Group toggle
    
    func toggleGroup(_ group: CardGroup) {
        if selectedGroups.contains(where: { $0.id == group.id }) {
            selectedGroups.removeAll { $0.id == group.id }
            availableGroups.append(group)
        } else {
            availableGroups.removeAll { $0.id == group.id }
            selectedGroups.append(group)
        }
    }
    
    // MARK: - Actions
    
    /// Возвращает true при успешном сохранении.
    func save() -> Bool {
        let trimmedOrigin = editedOrigin.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTranslated = editedTranslated.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedOrigin.isEmpty, !trimmedTranslated.isEmpty else { return false }
        
        do {
            let wordsChanged = trimmedOrigin != originalOrigin || trimmedTranslated != originalTranslated
            if wordsChanged {
                let exists = try cardRepository.exists(
                    origin: trimmedOrigin,
                    translated: trimmedTranslated,
                    excluding: card.id
                )
                if exists {
                    showDuplicateAlert = true
                    return false
                }
            }
            
            try cardRepository.update(
                card,
                origin: trimmedOrigin,
                translated: trimmedTranslated,
                groups: selectedGroups
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Возвращает true при успешном удалении.
    func delete() -> Bool {
        do {
            try cardRepository.delete(card)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
