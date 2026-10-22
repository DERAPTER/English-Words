//
//  ImportDataViewModel.swift
//  English Words
//
//  Created by Егор Халиков on 21.10.2026.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ImportGroupDTO: Codable {
    let name: String
    let cards: [ImportCardDTO]
}

struct ImportCardDTO: Codable {
    let origin: String
    let translated: String
    let originDescription: String?
    let translatedDescription: String?
}

@MainActor
@Observable
final class ImportDataViewModel {
    
    // MARK: - Templates (static)
    
    static let jsonTemplate = """
    [
      {
        "name": "Название группы",
        "cards": [
          {
            "origin": "word",
            "translated": "перевод",
            "originDescription": "",
            "translatedDescription": ""
          }
        ]
      }
    ]
    """
    
    static var aiPromptTemplate: String {
        let localizedPrompt = "import_ai_prompt_text".localized()
        return "\(localizedPrompt)\n\n\(jsonTemplate)"
    }
    
    // MARK: - State
    
    var jsonText: String = ""
    var showFileImporter = false
    var errorMessage: String?
    
    var showDuplicateAlert = false
    var showSuccessAlert = false
    var successMessage = ""
    
    private var parsedGroups: [ImportGroupDTO] = []
    private let cardRepository: CardRepository
    private let groupRepository: GroupRepository
    private let onComplete: () -> Void
    
    init(cardRepository: CardRepository, groupRepository: GroupRepository, onComplete: @escaping () -> Void) {
        self.cardRepository = cardRepository
        self.groupRepository = groupRepository
        self.onComplete = onComplete
    }
    
    // MARK: - Paste from clipboard
    
    func pasteFromClipboard() {
        guard let string = UIPasteboard.general.string, !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "import_error_empty_clipboard".localized()
            jsonText = ""
            return
        }
        jsonText = string
        errorMessage = nil
        
        // Тактильный отклик, что текст вставился
        HapticService.shared.success()
    }
    
    // MARK: - File Handling
    
    func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            defer { if didStartAccessing { url.stopAccessingSecurityScopedResource() } }
            
            do {
                let data = try Data(contentsOf: url)
                if let text = String(data: data, encoding: .utf8) {
                    jsonText = text
                    errorMessage = nil
                    HapticService.shared.success()
                } else {
                    errorMessage = "import_error_encoding".localized()
                }
            } catch {
                errorMessage = "import_error_file".localized()
            }
        case .failure:
            errorMessage = "import_error_file".localized()
        }
    }
    
    // MARK: - Import Logic (без изменений)
    
    func startImport(from text: String) {
        errorMessage = nil
        
        guard let data = text.data(using: .utf8) else {
            errorMessage = "import_error_format".localized()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let groups = try decoder.decode([ImportGroupDTO].self, from: data)
            
            if groups.isEmpty {
                errorMessage = "import_error_empty".localized()
                return
            }
            
            let hasDuplicates = try checkForDuplicates(groups: groups)
            self.parsedGroups = groups
            
            if hasDuplicates {
                showDuplicateAlert = true
            } else {
                performImport(groups: groups, skipDuplicates: false)
            }
            
        } catch {
            errorMessage = "import_error_parse".localized()
        }
    }
    
    func confirmImportWithDuplicates() {
        performImport(groups: parsedGroups, skipDuplicates: true)
    }
    
    private func checkForDuplicates(groups: [ImportGroupDTO]) throws -> Bool {
        var hasDupes = false
        
        for group in groups {
            if try groupRepository.nameExists(group.name, excluding: nil) {
                hasDupes = true
            }
            
            for card in group.cards {
                if try cardRepository.exists(origin: card.origin, translated: card.translated, excluding: nil) {
                    hasDupes = true
                    break
                }
            }
            if hasDupes { break }
        }
        return hasDupes
    }
    
    private func performImport(groups: [ImportGroupDTO], skipDuplicates: Bool) {
        do {
            var importedCardsCount = 0
            
            for groupDTO in groups {
                let existingGroup = try groupRepository.fetchUserGroups().first { $0.name == groupDTO.name }
                let targetGroup: CardGroup
                
                if let existing = existingGroup {
                    if skipDuplicates {
                        targetGroup = existing
                    } else {
                        continue
                    }
                } else {
                    targetGroup = try groupRepository.create(name: groupDTO.name)
                }
                
                for cardDTO in groupDTO.cards {
                    if skipDuplicates, try cardRepository.exists(origin: cardDTO.origin, translated: cardDTO.translated, excluding: nil) {
                        continue
                    }
                    
                    _ = try cardRepository.create(
                        origin: cardDTO.origin,
                        translated: cardDTO.translated,
                        originDescription: cardDTO.originDescription ?? "",
                        translatedDescription: cardDTO.translatedDescription ?? "",
                        groups: [targetGroup]
                    )
                    importedCardsCount += 1
                }
            }
            
            successMessage = String(format: "import_success_message".localized(), importedCardsCount)
            showSuccessAlert = true
            onComplete()
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
