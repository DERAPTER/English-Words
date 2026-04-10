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
    
    // Состояния для выбора существующих карточек
    @State private var addMode: AddCardMode = .createNew
    @State private var existingCards: [Card] = []
    @State private var searchText = ""
    @State private var selectedCards: Set<UUID> = []
    @State private var showSelectionAlert = false
    
    enum AddCardMode {
        case createNew
        case chooseExisting
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Переключатель режимов
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
                            
                            // Выбранные группы (только для режима создания)
                            selectedGroupsSection
                            
                            // Доступные группы (только для режима создания)
                            availableGroupsSection
                            
                            saveButton
                            
                        } else {
                            // Режим выбора существующих карточек
                            VStack(spacing: 16) {
                                searchField
                                
                                // Фиксированная область для информации о выборе (занимает место всегда)
                                selectionInfoArea
                                
                                existingCardsList
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(addMode == .createNew ? "new_card".localized() : "choose_cards".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized()) { showSheet = false }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if addMode == .chooseExisting && !selectedCards.isEmpty {
                        Button("add_selected".localized()) {
                            addSelectedCards()
                        }
                        .foregroundColor(.accent)
                    }
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
        .alert("cards_added".localized(), isPresented: $showSelectionAlert) {
            Button("ok".localized(), role: .cancel) { }
        } message: {
            Text(String(format: "cards_added_message".localized(), selectedCards.count, group.displayName))
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
    
    // MARK: - Выбор существующих карточек
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            TextField("search_card".localized(), text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.stroke, lineWidth: 1)
        )
    }
    
    // Фиксированная область для информации о выборе (всегда занимает место)
    private var selectionInfoArea: some View {
        HStack {
            if selectedCards.isEmpty {
                Text("select_cards_hint".localized())
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
            } else {
                Text(String(format: "selected_cards_count".localized(), selectedCards.count))
                    .font(.captionCustom)
                    .foregroundColor(.accent)
            }
            
            Spacer()
            
            if !selectedCards.isEmpty {
                Button("clear_all".localized()) {
                    withAnimation {
                        selectedCards.removeAll()
                    }
                }
                .font(.captionCustom)
                .foregroundColor(.red)
            }
        }
        .frame(height: 30)  // Фиксированная высота
        .padding(.horizontal, 4)
    }
    
    private var existingCardsList: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                        SelectableCardRow(
                            card: card,
                            isSelected: selectedCards.contains(card.id),
                            isAlreadyInGroup: isCardInCurrentGroup(card),
                            onToggle: { toggleSelection(card) }
                        )
                    }
                }
            }
        }
    }
    
    private func loadExistingCards() {
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
    
    private func isCardInCurrentGroup(_ card: Card) -> Bool {
        let targetGroup = cardsManager.getGroup(by: group.name)
        return targetGroup?.cardsArr.contains(where: { $0.id == card.id }) ?? false
    }
    
    private func toggleSelection(_ card: Card) {
        withAnimation {
            if selectedCards.contains(card.id) {
                selectedCards.remove(card.id)
            } else {
                if !isCardInCurrentGroup(card) {
                    selectedCards.insert(card.id)
                }
            }
        }
    }
    
    private func addSelectedCards() {
        let cardsToAdd = existingCards.filter { selectedCards.contains($0.id) }
        
        for card in cardsToAdd {
            cardsManager.addCardToGroup(card: card, groupName: group.name)
        }
        
        showSelectionAlert = true
        selectedCards.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showSheet = false
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

// MARK: - Selectable Card Row
struct SelectableCardRow: View {
    let card: Card
    let isSelected: Bool
    let isAlreadyInGroup: Bool
    let onToggle: () -> Void
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                // Индикатор выбора
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .accent : (isAlreadyInGroup ? .gray : .textSecondary))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.originWord)
                        .font(.bodyCustom)
                        .foregroundColor(isAlreadyInGroup ? .textSecondary : .textPrimary)
                        
                    
                    Text(card.translatedWord)
                        .font(.captionCustom)
                        .foregroundColor(isAlreadyInGroup ? .textSecondary : .textSecondary)
                        
                }
                
                Spacer()
                
                if isAlreadyInGroup {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                        Text("already_in_group".localized())
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.accent)  // Или Color.accent
                            .shadow(color: Color.orange.opacity(1), radius: 2, x: 0, y: 1)
                    )
                }
            }
            .padding()
            .background(
                isAlreadyInGroup ? Color.gray.opacity(0.22) : (isSelected ? Color.accent.opacity(0.2) : Color.cardBackground)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isAlreadyInGroup ? Color.gray.opacity(0.3) : (isSelected ? Color.accent : Color.stroke),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isAlreadyInGroup)
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
