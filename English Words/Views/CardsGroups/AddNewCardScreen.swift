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
                    // Поле оригинал
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

                    // Поле перевод
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

                    // Группы: выбранные
                    if !selectedGroups.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("selected_groups".localized())
                                .font(.captionCustom)
                                .foregroundColor(.textSecondary)
                            FlowLayout(spacing: 8) {
                                ForEach(selectedGroups) { grp in
                                    GroupChip(name: grp.name, isSelected: true) {
                                        selectedGroups.removeAll { $0.id == grp.id }
                                        unselectedGroups.append(grp)
                                    }
                                }
                            }
                        }
                    }

                    // Доступные группы
                    if !unselectedGroups.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("available_groups".localized())
                                .font(.captionCustom)
                                .foregroundColor(.textSecondary)
                            FlowLayout(spacing: 8) {
                                ForEach(unselectedGroups) { grp in
                                    GroupChip(name: grp.name, isSelected: false) {
                                        unselectedGroups.removeAll { $0.id == grp.id }
                                        selectedGroups.append(grp)
                                    }
                                }
                            }
                        }
                    }

                    // Кнопка сохранения
                    Button(action: saveCard) {
                        Text("save_card".localized())
                            .font(.bodyCustom.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(originWord.isEmpty || translatedWord.isEmpty ? Color.gray : Color.accent)
                            .cornerRadius(16)
                    }
                    .disabled(originWord.isEmpty || translatedWord.isEmpty)
                    .opacity(originWord.isEmpty || translatedWord.isEmpty ? 0.6 : 1)
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
            selectedGroups = [cardsManager.groups[0], group]
            unselectedGroups = cardsManager.groups.filter { grp in
                !selectedGroups.contains(where: { $0.id == grp.id })
            }
        }
        .alert("duplicate_card_title".localized(), isPresented: $showDuplicateAlert) {
            Button("ok".localized(), role: .cancel) { }
        } message: {
            Text("duplicate_card_message".localized())
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
        for grp in selectedGroups {
            cardsManager.addCardToGroup(card: card, groupName: grp.name)
        }
        showSheet = false
    }
}

// MARK: - GroupChip
struct GroupChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
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
