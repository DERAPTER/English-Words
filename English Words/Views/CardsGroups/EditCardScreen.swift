//
//  EditCardScreen.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct EditCardScreen: View {
    @ObservedObject var cardsManager: CardsManager
    @ObservedObject var card: Card
    @Environment(\.dismiss) var dismiss
    
    @State private var editedOrigin: String
    @State private var editedTranslation: String
    @State private var selectedGroups: [CardsGroup] = []
    @State private var unselectedGroups: [CardsGroup] = []
    @State private var showDeleteConfirmation = false
    @State private var showDuplicateAlert = false
    
    init(cardsManager: CardsManager, card: Card) {
        self.cardsManager = cardsManager
        self.card = card
        _editedOrigin = State(initialValue: card.originWord)
        _editedTranslation = State(initialValue: card.translatedWord)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок
                Text("edit_card".localized())
                    .font(.largeTitleCustom)
                    .foregroundColor(.textPrimary)
                    .padding(.top, 20)
                
                // Поля ввода
                VStack(alignment: .leading, spacing: 16) {
                    // Оригинал
                    VStack(alignment: .leading, spacing: 8) {
                        Text("original_word".localized())
                            .font(.bodyCustom)
                            .foregroundColor(.textSecondary)
                        TextField("", text: $editedOrigin)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                    }
                    
                    // Перевод
                    VStack(alignment: .leading, spacing: 8) {
                        Text("translation".localized())
                            .font(.bodyCustom)
                            .foregroundColor(.textSecondary)
                        TextField("", text: $editedTranslation)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                
                // MARK: - Управление группами (НОВОЕ)
                VStack(alignment: .leading, spacing: 16) {
                    Text("groups_management".localized())
                        .font(.titleCustom)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal)
                    
                    // Выбранные группы
                    if !selectedGroups.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("selected_groups".localized())
                                .font(.captionCustom)
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(selectedGroups) { group in
                                    GroupChip(
                                        group: group,
                                        isSelected: true
                                    ) {
                                        withAnimation {
                                            moveGroup(group, from: &selectedGroups, to: &unselectedGroups)
                                            removeCardFromGroup(group)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Доступные группы (исключая All Cards и уже выбранные)
                    let availableGroups = getAvailableGroups()
                    if !availableGroups.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("available_groups".localized())
                                .font(.captionCustom)
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(availableGroups) { group in
                                    GroupChip(
                                        group: group,
                                        isSelected: false
                                    ) {
                                        withAnimation {
                                            moveGroup(group, from: &unselectedGroups, to: &selectedGroups)
                                            addCardToGroup(group)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Информация о карточке
                VStack(alignment: .leading, spacing: 16) {
                    Text("card_info".localized())
                        .font(.titleCustom)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal)
                    
                    Stat1Row(title: "creation_date".localized(),
                            value: card.dateAdded.formatted(date: .abbreviated, time: .omitted))
                }
                
                // Статистика ответов
                VStack(alignment: .leading, spacing: 16) {
                    Text("answer_statistics".localized())
                        .font(.titleCustom)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal)
                    
                    Stat1Row(title: "correct".localized(), value: "\(card.correctCount)", color: .correct)
                    Stat1Row(title: "wrong".localized(), value: "\(card.wrongCount)", color: .wrong)
                    Stat1Row(title: "total_attempts".localized(), value: "\(card.correctCount + card.wrongCount)")
                    
                    if card.correctCount + card.wrongCount > 0 {
                        let successRate = Double(card.correctCount) / Double(card.correctCount + card.wrongCount) * 100
                        Stat1Row(title: "success_rate".localized(),
                                value: String(format: "%.1f%%", successRate),
                                color: .accent)
                    }
                }
                
                // Кнопка сохранения
                Button(action: saveChanges) {
                    Text("save_changes".localized())
                        .font(.bodyCustom.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(editedOrigin.isEmpty || editedTranslation.isEmpty ? Color.gray : Color.accent)
                        .cornerRadius(16)
                }
                .disabled(editedOrigin.isEmpty || editedTranslation.isEmpty)
                .padding(.horizontal)
                
                // Кнопка удаления
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.title2)
                        Text("delete_card".localized())
                            .font(.bodyCustom)
                    }
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.stroke, lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .languageAware()
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCardGroups()
        }
        .alert("delete_card_confirmation".localized(), isPresented: $showDeleteConfirmation) {
            Button("cancel".localized(), role: .cancel) { }
            Button("delete".localized(), role: .destructive) {
                deleteCard()
            }
        } message: {
            Text("delete_card_message".localized())
        }
        .alert("duplicate_card_title".localized(), isPresented: $showDuplicateAlert) {
            Button("ok".localized(), role: .cancel) { }
        } message: {
            Text("duplicate_card_message".localized())
        }
    }
    
    // MARK: - Group Management
    
    private func loadCardGroups() {
        // Получаем все группы, исключая "All Cards"
        let allGroups = cardsManager.groups.filter { $0.name != "All Cards" }
        
        // Группы, в которых есть карточка
        selectedGroups = allGroups.filter { group in
            card.groups.contains(group.name)
        }
        
        // Группы, в которых нет карточки
        unselectedGroups = allGroups.filter { group in
            !card.groups.contains(group.name)
        }
    }
    
    private func getAvailableGroups() -> [CardsGroup] {
        // Возвращаем невыбранные группы (кроме All Cards)
        return unselectedGroups
    }
    
    private func moveGroup(_ group: CardsGroup, from: inout [CardsGroup], to: inout [CardsGroup]) {
        from.removeAll { $0.id == group.id }
        to.append(group)
    }
    
    private func addCardToGroup(_ group: CardsGroup) {
        cardsManager.addCardToGroup(card: card, groupName: group.name)
    }
    
    private func removeCardFromGroup(_ group: CardsGroup) {
        cardsManager.removeCardFromGroup(card: card, groupName: group.name)
    }
    
    // MARK: - Actions
    
    private func saveChanges() {
        // Проверка на дубликат (если изменились слова)
        if editedOrigin != card.originWord || editedTranslation != card.translatedWord {
            let allCardsGroup = cardsManager.getGroup(by: "All Cards")
            let cardExists = allCardsGroup?.cardsArr.contains { existingCard in
                existingCard.id != card.id &&
                existingCard.originWord.lowercased() == editedOrigin.lowercased() &&
                existingCard.translatedWord.lowercased() == editedTranslation.lowercased()
            } ?? false
            
            if cardExists {
                showDuplicateAlert = true
                return
            }
        }
        
        card.originWord = editedOrigin
        card.translatedWord = editedTranslation
        dismiss()
    }
    
    private func deleteCard() {
        cardsManager.deleteCard(card)
        dismiss()
    }
}

// MARK: - StatRow
struct Stat1Row: View {
    let title: String
    let value: String
    var color: Color = .textPrimary
    
    var body: some View {
        HStack {
            Text(title)
                .font(.bodyCustom)
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.titleCustom)
                .foregroundColor(color)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .shadowColor, radius: 4, x: 0, y: 1)
        .padding(.horizontal)
    }
}
