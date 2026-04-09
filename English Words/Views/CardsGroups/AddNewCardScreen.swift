//
//  AddNewCardScreen.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct AddNewCardScreen: View {
    let group: CardsGroup
    @ObservedObject var cardsManager: CardsManager
    @Binding var showSheet: Bool

    @State private var originWord = ""
    @State private var translatedWord = ""
    @State private var selectedGroups: [CardsGroup] = []
    @State private var unselectedGroups: [CardsGroup] = []
    @State private var showDuplicateAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    originWordField
                    translatedWordField
                    //infoMessage
                    selectedGroupsSection
                    availableGroupsSection
                    saveButton
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("new_card".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized()) { showSheet = false }
                }
            }
        }
        .onAppear {
            setupGroups()
        }
        .alert("duplicate_card_title".localized(), isPresented: $showDuplicateAlert) {
            Button("ok".localized(), role: .cancel) { }
        } message: {
            Text("duplicate_card_message".localized())
        }
    }
    
    // MARK: - UI Components
    
    private var originWordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("original_word".localized())
                .font(.bodyCustom)
                .foregroundColor(.textPrimary)
            TextField("enter_word".localized(), text: $originWord)
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
    
    private var translatedWordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("translation".localized())
                .font(.bodyCustom)
                .foregroundColor(.textPrimary)
            TextField("enter_translation".localized(), text: $translatedWord)
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
    
    /*
    private var infoMessage: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                Text("card_will_be_added_to_all_cards".localized())
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 4)
        }
    }
     */
    
    @ViewBuilder
    private var selectedGroupsSection: some View {
        if !selectedGroups.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("selected_groups".localized())
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
                FlowLayout(spacing: 8) {
                    ForEach(selectedGroups) { grp in
                        GroupChip(group: grp, isSelected: true) {
                            withAnimation {
                                selectedGroups.removeAll { $0.id == grp.id }
                                unselectedGroups.append(grp)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var availableGroupsSection: some View {
        if !unselectedGroups.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("available_groups".localized())
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
                FlowLayout(spacing: 8) {
                    ForEach(unselectedGroups) { grp in
                        GroupChip(group: grp, isSelected: false) {
                            withAnimation {
                                unselectedGroups.removeAll { $0.id == grp.id }
                                selectedGroups.append(grp)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: saveCard) {
            Text("save_card".localized())
                .font(.bodyCustom.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSave ? Color.accent : Color.gray)
                .cornerRadius(16)
        }
        .disabled(!canSave)
        .opacity(canSave ? 1 : 0.6)
    }
    
    private var canSave: Bool {
        !originWord.isEmpty && !translatedWord.isEmpty
    }

    // MARK: - Logic
    
    private func setupGroups() {
        // Фильтруем все группы, исключая "All Cards"
        let allNonSystemGroups = cardsManager.groups.filter { $0.name != "All Cards" }
        
        // Выбранные группы: текущая группа (если она не "All Cards")
        var selected: [CardsGroup] = []
        if group.name != "All Cards" {
            selected.append(group)
        }
        
        selectedGroups = selected
        
        // Доступные группы: все несистемные, кроме уже выбранных
        unselectedGroups = allNonSystemGroups.filter { nonSystemGroup in
            !selectedGroups.contains(where: { $0.id == nonSystemGroup.id })
        }
    }

    private func saveCard() {
        // Проверяем, существует ли уже такая карточка
        let allCardsGroup = cardsManager.getGroup(by: "All Cards")
        let cardExists = allCardsGroup?.cardsArr.contains { existingCard in
            existingCard.originWord.lowercased() == originWord.lowercased() &&
            existingCard.translatedWord.lowercased() == translatedWord.lowercased()
        } ?? false
        
        if cardExists {
            showDuplicateAlert = true
            return
        }
        
        let card = Card(origin: originWord, translate: translatedWord)
        
        // Всегда добавляем в "All Cards"
        cardsManager.addCardToGroup(card: card, groupName: "All Cards")
        
        // Добавляем в выбранные пользователем группы
        for grp in selectedGroups {
            cardsManager.addCardToGroup(card: card, groupName: grp.name)
        }
        
        showSheet = false
    }
}

// MARK: - GroupChip (ОБНОВЛЁННЫЙ)
struct GroupChip: View {
    let group: CardsGroup
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(group.displayName)
                .font(.captionCustom)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accent : Color.cardBackground)
                .cornerRadius(20)
                .overlay(
                    Capsule()
                        .stroke(Color.stroke, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
