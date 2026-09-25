//
//  AddCardView.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

//
//  AddCardSheet.swift
//  English Words
//

import SwiftUI

struct AddCardSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: AddCardViewModel
    private let onComplete: () -> Void
    
    init(
        group: CardGroup,
        cardRepository: CardRepository,
        groupRepository: GroupRepository,
        onComplete: @escaping () -> Void
    ) {
        self.onComplete = onComplete
        _viewModel = State(initialValue: AddCardViewModel(
            targetGroup: group,
            cardRepository: cardRepository,
            groupRepository: groupRepository
        ))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                modePicker
                
                ScrollView {
                    VStack(spacing: 24) {
                        switch viewModel.mode {
                        case .createNew:
                            createNewContent
                        case .chooseExisting:
                            chooseExistingContent
                        }
                    }
                    .padding()
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onAppear { viewModel.onAppear() }
            .alert("duplicate_card_title".localized(), isPresented: $viewModel.showDuplicateAlert) {
                Button("ok".localized(), role: .cancel) { }
            } message: {
                Text("duplicate_card_message".localized())
            }
            .alert("cards_added".localized(), isPresented: $viewModel.showSuccessAlert) {
                Button("ok".localized(), role: .cancel) {
                    onComplete()
                    dismiss()
                }
            } message: {
                Text(String(format: "cards_added_message".localized(),
                            viewModel.addedCardsCount,
                            viewModel.targetGroupName))
            }
        }
    }
    
    private var navigationTitle: String {
        viewModel.mode == .createNew
            ? "new_card".localized()
            : "choose_cards".localized()
    }
    
    // MARK: - Subviews
    
    private var modePicker: some View {
        Picker("add_card_mode".localized(), selection: $viewModel.mode) {
            Text("create_new".localized()).tag(AddCardViewModel.Mode.createNew)
            Text("choose_existing".localized()).tag(AddCardViewModel.Mode.chooseExisting)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    @ViewBuilder
    private var createNewContent: some View {
        WordInputField(
            title: "original_word".localized(),
            placeholder: "enter_word".localized(),
            text: $viewModel.originWord
        )
        
        WordInputField(
            title: "translation".localized(),
            placeholder: "enter_translation".localized(),
            text: $viewModel.translatedWord
        )
        
        if !viewModel.selectedGroups.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("selected_groups".localized())
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.selectedGroups) { group in
                        GroupChip(group: group, isSelected: true) {
                            viewModel.toggleGroup(group)
                        }
                    }
                }
            }
        }
        
        if !viewModel.availableGroups.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("available_groups".localized())
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.availableGroups) { group in
                        GroupChip(group: group, isSelected: false) {
                            viewModel.toggleGroup(group)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var chooseExistingContent: some View {
        CardSearchBar(text: $viewModel.searchText)
        
        selectionInfoArea
        
        existingCardsList
    }
    
    private var selectionInfoArea: some View {
        HStack {
            if viewModel.selectedCardIDs.isEmpty {
                Text("select_cards_hint".localized())
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
            } else {
                Text(String(format: "selected_cards_count".localized(), viewModel.selectedCardIDs.count))
                    .font(.captionCustom)
                    .foregroundColor(.accent)
            }
            
            Spacer()
            
            if !viewModel.selectedCardIDs.isEmpty {
                Button("clear_all".localized()) {
                    withAnimation { viewModel.clearSelection() }
                }
                .font(.captionCustom)
                .foregroundColor(.red)
            }
        }
        .frame(height: 30)
        .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    private var existingCardsList: some View {
        if viewModel.filteredExistingCards.isEmpty {
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
                ForEach(viewModel.filteredExistingCards) { card in
                    SelectableCardRow(
                        card: card,
                        isSelected: viewModel.selectedCardIDs.contains(card.id),
                        isAlreadyInGroup: viewModel.isCardInTargetGroup(card),
                        onToggle: { viewModel.toggleCardSelection(card) }
                    )
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("cancel".localized()) { dismiss() }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            switch viewModel.mode {
            case .createNew:
                Button("save_card".localized()) {
                    if viewModel.saveNewCard() {
                        onComplete()
                        dismiss()
                    }
                }
                .disabled(!viewModel.canSaveNewCard)
                .foregroundColor(viewModel.canSaveNewCard ? .accent : .gray)
                
            case .chooseExisting:
                Button("add_selected".localized()) {
                    viewModel.addSelectedCardsToGroup()
                }
                .disabled(!viewModel.canAddSelected)
                .foregroundColor(viewModel.canAddSelected ? .accent : .gray)
            }
        }
    }
}
