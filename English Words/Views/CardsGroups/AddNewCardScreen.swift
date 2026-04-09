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
    
    // НОВЫЕ СОСТОЯНИЯ для выбора существующей карточки
    @State private var addMode: AddCardMode = .createNew
    @State private var existingCards: [Card] = []
    @State private var searchText = ""
    
    enum AddCardMode {
        case createNew
        case chooseExisting
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Переключатель между созданием новой и выбором существующей
                Picker("add_card_mode".localized(), selection: $addMode) {
                    Text("create_new".localized()).tag(AddCardMode.createNew)
                    Text("choose_existing".localized()).tag(AddCardMode.chooseExisting)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 12)
                
                ScrollView {
                    VStack(spacing: 24) {
                        if addMode == .createNew {
                            // Режим создания новой карточки
                            VStack(spacing: 16) {
                                originWordField
                                translatedWordField
                            }
                            
                            infoMessage
                            
                        } else {
                            // Режим выбора существующей карточки
                            existingCardsContent
                        }
                        
                        // Выбранные группы
                        selectedGroupsSection
                        
                        // Доступные группы
                        availableGroupsSection
                        
                        // Кнопка сохранения (только для режима создания новой)
                        if addMode == .createNew {
                            saveButton
                        }
                    }
                    .padding()
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(addMode == .createNew ? "new_card".localized() : "choose_card".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized()) { showSheet = false }
                }
            }
        }
        .onAppear {
            setupGroups()
            loadExistingCards()
        }
        .alert("duplicate_card_title".localized(), isPresented: $showDuplicateAlert) {
            Button("ok".localized(), role: .cancel) { }
        } message: {
            Text("duplicate_card_message".localized())
        }
    }
    
    // MARK: - Новая карточка
    
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
    
    // MARK: - Выбор существующей карточки
    
    @ViewBuilder
    private var existingCardsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Поле поиска
            TextField("search_card".localized(), text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.stroke, lineWidth: 1)
                )
            
            // Список существующих карточек (без вложенного ScrollView)
            if filteredExistingCards.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(.textSecondary)
                    Text("no_cards_found".localized())
                        .font(.bodyCustom)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(filteredExistingCards) { card in
                        ExistingCardRow(
                            card: card,
                            isSelected: isCardSelected(card),
                            onSelect: { selectExistingCard(card) }
                        )
                    }
                }
            }
        }
    }
    
    private func loadExistingCards() {
        // Загружаем все карточки из группы "All Cards"
        if let allCardsGroup = cardsManager.getGroup(by: "All Cards") {
            existingCards = allCardsGroup.cardsArr
        }
    }
    
    private var filteredExistingCards: [Card] {
        if searchText.isEmpty {
            return existingCards
        }
        return existingCards.filter { card in
            card.originWord.localizedCaseInsensitiveContains(searchText) ||
            card.translatedWord.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func isCardSelected(_ card: Card) -> Bool {
        // Проверяем, есть ли карточка уже в целевой группе
        let targetGroup = cardsManager.getGroup(by: group.name)
        return targetGroup?.cardsArr.contains(where: { $0.id == card.id }) ?? false
    }
    
    private func selectExistingCard(_ card: Card) {
        // Добавляем существующую карточку в текущую группу
        cardsManager.addCardToGroup(card: card, groupName: group.name)
        
        // Также добавляем в выбранные пользователем группы
        for grp in selectedGroups where grp.name != group.name {
            cardsManager.addCardToGroup(card: card, groupName: grp.name)
        }
        
        showSheet = false
    }
    
    // MARK: - Общие компоненты
    
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
        let allNonSystemGroups = cardsManager.groups.filter { $0.name != "All Cards" }
        
        var selected: [CardsGroup] = []
        if group.name != "All Cards" {
            selected.append(group)
        }
        
        selectedGroups = selected
        unselectedGroups = allNonSystemGroups.filter { nonSystemGroup in
            !selectedGroups.contains(where: { $0.id == nonSystemGroup.id })
        }
    }

    private func saveCard() {
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
        
        cardsManager.addCardToGroup(card: card, groupName: "All Cards")
        
        for grp in selectedGroups {
            cardsManager.addCardToGroup(card: card, groupName: grp.name)
        }
        
        showSheet = false
    }
}

// MARK: - ExistingCardRow
struct ExistingCardRow: View {
    let card: Card
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.originWord)
                        .font(.bodyCustom)
                        .foregroundColor(.textPrimary)
                    Text(card.translatedWord)
                        .font(.captionCustom)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accent)
                } else {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accent)
                }
            }
            .padding()
            .background(isSelected ? Color.accent.opacity(0.15) : Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accent : Color.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isSelected)
    }
}

// MARK: - GroupChip
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
