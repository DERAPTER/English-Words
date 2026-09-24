//
//  SwiftDataGroupRepository.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation
import SwiftData

final class SwiftDataGroupRepository: GroupRepository {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Fetch
    
    func fetchUserGroups() throws -> [CardGroup] {
        let predicate = #Predicate<CardGroup> { $0.systemTypeRaw == nil }
        let descriptor = FetchDescriptor<CardGroup>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.orderIndex, order: .forward)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    func fetch(id: UUID) throws -> CardGroup? {
        let predicate = #Predicate<CardGroup> { $0.id == id }
        var descriptor = FetchDescriptor<CardGroup>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            return try context.fetch(descriptor).first
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    func userGroupsCount() throws -> Int {
        let predicate = #Predicate<CardGroup> { $0.systemTypeRaw == nil }
        do {
            return try context.fetchCount(FetchDescriptor<CardGroup>(predicate: predicate))
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    // MARK: - Mutations
    
    func create(name: String) throws -> CardGroup {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw RepositoryError.invalidInput(reason: "Название группы не может быть пустым")
        }
        
        if try nameExists(trimmed, excluding: nil) {
            throw RepositoryError.invalidInput(reason: "Группа с таким названием уже существует")
        }
        
        let nextIndex = try nextOrderIndex()
        let group = CardGroup(name: trimmed, orderIndex: nextIndex)
        context.insert(group)
        try save()
        return group
    }
    
    func rename(_ group: CardGroup, to newName: String) throws {
        guard !group.isSystem else {
            throw RepositoryError.invalidInput(reason: "Системную группу нельзя переименовать")
        }
        
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw RepositoryError.invalidInput(reason: "Название группы не может быть пустым")
        }
        
        if try nameExists(trimmed, excluding: group.id) {
            throw RepositoryError.invalidInput(reason: "Группа с таким названием уже существует")
        }
        
        group.name = trimmed
        try save()
    }
    
    func delete(_ group: CardGroup) throws {
        guard !group.isSystem else {
            throw RepositoryError.invalidInput(reason: "Системную группу нельзя удалить")
        }
        context.delete(group)
        try save()
    }
    
    func addCard(_ card: Card, to group: CardGroup) throws {
        guard !card.groups.contains(where: { $0.id == group.id }) else { return }
        card.groups.append(group)
        try save()
    }
    
    func removeCard(_ card: Card, from group: CardGroup) throws {
        card.groups.removeAll { $0.id == group.id }
        try save()
    }
    
    // MARK: - Validation
    
    func nameExists(_ name: String, excluding groupID: UUID?) throws -> Bool {
        let lower = name.lowercased()
        do {
            let all = try context.fetch(FetchDescriptor<CardGroup>())
            return all.contains { group in
                if let excludeID = groupID, group.id == excludeID { return false }
                return group.name.lowercased() == lower
            }
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    // MARK: - Private
    
    private func nextOrderIndex() throws -> Int {
        let descriptor = FetchDescriptor<CardGroup>(
            sortBy: [SortDescriptor(\.orderIndex, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        do {
            let last = try context.fetch(descriptor).first
            return (last?.orderIndex ?? -1) + 1
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
    
    private func save() throws {
        do {
            try context.save()
        } catch {
            throw RepositoryError.saveFailed(underlying: error)
        }
    }
}
