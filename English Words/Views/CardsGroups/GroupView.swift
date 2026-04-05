//
//  GroupView.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

// MARK: - Swiped Item Enum
enum SwipedItem: Equatable {
    case none
    case group(id: UUID)
    case card(id: UUID)
}

// MARK: - Delete Type Enum (НОВЫЙ - добавляем сюда)
enum DeleteType {
    case fromGroup
    case completely
}

// MARK: - Swipeable Group Header
struct SwipeableGroupHeader: View {
    let group: CardsGroup
    @Binding var isExpanded: Bool
    @ObservedObject var cardsManager: CardsManager
    @Binding var swipedItem: SwipedItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    // НОВОЕ: алерт для системной группы
    @State private var showSystemGroupAlert = false
    @State private var systemAlertMessage = ""

    var body: some View {
        ZStack(alignment: .trailing) {
            if swipedItem == .group(id: group.id) {
                HStack(spacing: 12) {
                    editButton
                    deleteButton
                }
                .padding(.trailing, 8)
            }

            groupContent
                .offset(x: swipedItem == .group(id: group.id) ? -135 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: swipedItem == .group(id: group.id))
        }
        .contentShape(Rectangle())
        .gesture(swipeGesture)
        .onTapGesture {
            handleTap()
        }
        .alert("system_group".localized(), isPresented: $showSystemGroupAlert) {
            Button("ok".localized(), role: .cancel) { }
        } message: {
            Text(systemAlertMessage)
        }
    }

    private var groupContent: some View {
        HStack {
            Text(group.name)
                .font(.titleCustom)
                .foregroundColor(.textPrimary)
            Spacer()
            Text("\(group.cards.cardsArr.count)")
                .font(.bodyCustom)
                .foregroundColor(.textSecondary)
            Image(systemName: "chevron.down")
                .font(.body)
                .foregroundColor(.textSecondary)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .shadowColor, radius: 8, x: 0, y: 2)
    }

    private var editButton: some View {
        Button(action: {
            withAnimation {
                swipedItem = .none
                onEdit()
            }
        }) {
            Image(systemName: "pencil")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.orange)
                .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var deleteButton: some View {
        Button(action: {
            withAnimation {
                swipedItem = .none
                // НОВОЕ: проверка на системную группу
                if cardsManager.isSystemGroup(group) {
                    systemAlertMessage = "system_group_cannot_delete".localized()
                    showSystemGroupAlert = true
                } else {
                    onDelete()
                }
            }
        }) {
            Image(systemName: "trash")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.red)
                .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                handleSwipe(value: value)
            }
            .onEnded { value in
                handleSwipeEnd(value: value)
            }
    }

    private func handleSwipe(value: DragGesture.Value) {
        let translation = value.translation.width
        
        if translation < -20 {
            if swipedItem != .group(id: group.id) && swipedItem != .none {
                swipedItem = .none
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        swipedItem = .group(id: group.id)
                    }
                }
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    swipedItem = .group(id: group.id)
                }
            }
        } else if translation > 20 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                swipedItem = .none
            }
        }
    }

    private func handleSwipeEnd(value: DragGesture.Value) {
        let translation = value.translation.width
        let predictedEnd = value.predictedEndTranslation.width
        
        if translation < -60 || predictedEnd < -100 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                swipedItem = .group(id: group.id)
            }
        } else if translation > 60 || predictedEnd > 100 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                swipedItem = .none
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if swipedItem == .group(id: group.id) && translation > -30 {
                    swipedItem = .none
                }
            }
        }
    }

    private func handleTap() {
        if swipedItem == .group(id: group.id) {
            withAnimation {
                swipedItem = .none
            }
        } else {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
}

// MARK: - Swipeable Card Row
struct SwipeableCardRow: View {
    let card: Card
    let group: CardsGroup
    @ObservedObject var cardsManager: CardsManager
    @Binding var swipedItem: SwipedItem
    var onEdit: () -> Void
    var onDeleteFromGroup: () -> Void
    var onDeleteCompletely: () -> Void
    
    @State private var showDeleteOptions = false

    var body: some View {
        ZStack(alignment: .trailing) {
            if swipedItem == .card(id: card.id) {
                HStack(spacing: 12) {
                    editButton
                    deleteButton
                }
                .padding(.trailing, 8)
            }

            CardInListView(card: card, cardsManager: cardsManager)
                .offset(x: swipedItem == .card(id: card.id) ? -135 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: swipedItem == .card(id: card.id))
        }
        .contentShape(Rectangle())
        .gesture(swipeGesture)
        .onTapGesture {
            handleTap()
        }
        .confirmationDialog("delete_card".localized(), isPresented: $showDeleteOptions, titleVisibility: .visible) {
            Button(String(format: "delete_from_group".localized(), group.name), role: .destructive) {
                onDeleteFromGroup()
            }
            Button("delete_completely".localized(), role: .destructive) {
                onDeleteCompletely()
            }
            Button("cancel".localized(), role: .cancel) { }
        } message: {
            Text("delete_card_choice_message".localized())
        }
    }

    private var editButton: some View {
        Button(action: {
            withAnimation {
                swipedItem = .none
                onEdit()
            }
        }) {
            Image(systemName: "pencil")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.orange)
                .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var deleteButton: some View {
        Button(action: {
            withAnimation {
                swipedItem = .none
                showDeleteOptions = true
            }
        }) {
            Image(systemName: "trash")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.red)
                .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                handleSwipe(value: value)
            }
            .onEnded { value in
                handleSwipeEnd(value: value)
            }
    }

    private func handleSwipe(value: DragGesture.Value) {
        let translation = value.translation.width
        
        if translation < -20 {
            if swipedItem != .card(id: card.id) && swipedItem != .none {
                swipedItem = .none
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        swipedItem = .card(id: card.id)
                    }
                }
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    swipedItem = .card(id: card.id)
                }
            }
        } else if translation > 20 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                swipedItem = .none
            }
        }
    }

    private func handleSwipeEnd(value: DragGesture.Value) {
        let translation = value.translation.width
        let predictedEnd = value.predictedEndTranslation.width
        
        if translation < -60 || predictedEnd < -100 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                swipedItem = .card(id: card.id)
            }
        } else if translation > 60 || predictedEnd > 100 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                swipedItem = .none
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if swipedItem == .card(id: card.id) && translation > -30 {
                    swipedItem = .none
                }
            }
        }
    }

    private func handleTap() {
        if swipedItem == .card(id: card.id) {
            withAnimation {
                swipedItem = .none
            }
        }
    }
}

// MARK: - Main GroupView (без изменений в основной структуре)
struct GroupView: View {
    @ObservedObject var cardsManager: CardsManager
    let group: CardsGroup
    @ObservedObject var cards: Cards

    @State private var isExpanded = false
    @State private var swipedItem: SwipedItem = .none
    
    @State private var showSheet = false

    @State private var groupToDelete: CardsGroup?
    @State private var showDeleteGroupAlert = false
    
    @State private var cardToDelete: Card?
    @State private var deleteType: DeleteType?

    @State private var groupToEdit: CardsGroup?
    @State private var cardToEdit: Card?

    init(group: CardsGroup, cardsManager: CardsManager) {
        self.group = group
        self.cardsManager = cardsManager
        self._cards = ObservedObject(wrappedValue: group.cards)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SwipeableGroupHeader(
                group: group,
                isExpanded: $isExpanded,
                cardsManager: cardsManager,
                swipedItem: $swipedItem,
                onEdit: { groupToEdit = group },
                onDelete: { confirmDeleteGroup() }
            )

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(cards.cardsArr) { card in
                        SwipeableCardRow(
                            card: card,
                            group: group,
                            cardsManager: cardsManager,
                            swipedItem: $swipedItem,
                            onEdit: { cardToEdit = card },
                            onDeleteFromGroup: { confirmDeleteCardFromGroup(card) },
                            onDeleteCompletely: { confirmDeleteCardCompletely(card) }
                        )
                    }

                    Button(action: { showSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("add_new_card".localized())
                                .font(.bodyCustom)
                        }
                        .foregroundColor(.accent)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.cardBackground.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.stroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                }
                .padding(.leading, 16)
            }
        }
        .sheet(isPresented: $showSheet) {
            AddNewCardScreen(group: group, cardsManager: cardsManager, showSheet: $showSheet)
        }
        .sheet(item: $groupToEdit) { group in
            EditGroupScreen(cardsManager: cardsManager, group: group)
        }
        .sheet(item: $cardToEdit) { card in
            EditCardScreen(cardsManager: cardsManager, card: card)
        }
        .alert("delete_group_confirmation".localized(), isPresented: $showDeleteGroupAlert) {
            Button("cancel".localized(), role: .cancel) {
                groupToDelete = nil
                closeSwipe()
            }
            Button("delete".localized(), role: .destructive) {
                if let group = groupToDelete {
                    deleteGroup(group)
                }
                groupToDelete = nil
            }
        } message: {
            if let group = groupToDelete {
                Text(String(format: "delete_group_message_format".localized(), group.name))
            }
        }
    }

    // MARK: - Actions
    private func closeSwipe() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            swipedItem = .none
        }
    }

    private func confirmDeleteGroup() {
        groupToDelete = group
        showDeleteGroupAlert = true
    }

    private func confirmDeleteCardFromGroup(_ card: Card) {
        cardsManager.removeCardFromGroup(card: card, groupName: group.name)
        closeSwipe()
    }

    private func confirmDeleteCardCompletely(_ card: Card) {
        cardsManager.deleteCard(card)
        closeSwipe()
    }

    private func deleteGroup(_ group: CardsGroup) {
        cardsManager.deleteGroup(group)
        closeSwipe()
    }
}
