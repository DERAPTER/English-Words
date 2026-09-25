//
//  GroupsListView.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI

struct GroupsListView: View {
    @Environment(AppContainer.self) private var container
    @State private var viewModel: GroupsListViewModel
    
    @State private var showAddGroupSheet = false
    @State private var groupToEdit: CardGroup?
    @State private var cardToEdit: Card?
    @State private var groupToDelete: CardGroup?
    @State private var showDeleteGroupAlert = false
    @State private var addCardToGroup: CardGroup?
    
    init(container: AppContainer) {
        _viewModel = State(initialValue: GroupsListViewModel(
            cardRepository: container.cardRepository,
            groupRepository: container.groupRepository
        ))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.displayItems) { item in
                        GroupRowView(
                            item: item,
                            viewModel: viewModel,
                            onEdit: handleEdit,
                            onDelete: handleDelete,
                            onEditCard: { cardToEdit = $0 },
                            onAddCard: { addCardToGroup = $0 }
                        )
                        .padding(.horizontal)
                    }
                    
                    addGroupButton
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                }
                .padding(.top, 8)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("groups_title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .task { viewModel.load() }
            .refreshable { viewModel.load() }
            .sheet(isPresented: $showAddGroupSheet) {
                AddGroupSheet(viewModel: viewModel, isPresented: $showAddGroupSheet)
            }
            .sheet(item: $groupToEdit) { group in
                EditGroupView(group: group)
                    .environment(container)
            }
            .sheet(item: $cardToEdit) { card in
                EditCardView(card: card)
                    .environment(container)
            }
            .sheet(item: $addCardToGroup) { group in
                AddCardSheet(group: group, onComplete: {
                    viewModel.handleCardAdded()
                })
                .environment(container)
            }
            .alert("delete_group_confirmation".localized(), isPresented: $showDeleteGroupAlert) {
                Button("cancel".localized(), role: .cancel) { groupToDelete = nil }
                Button("delete".localized(), role: .destructive) {
                    if let group = groupToDelete {
                        try? viewModel.deleteGroup(group)
                    }
                    groupToDelete = nil
                }
            } message: {
                if let group = groupToDelete {
                    Text(String(format: "delete_group_message_format".localized(), group.name))
                }
            }
        }
    }
    
    private var addGroupButton: some View {
        Button {
            showAddGroupSheet = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("add_new_group".localized())
                    .font(.bodyCustom)
            }
            .foregroundColor(.accent)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func handleEdit(_ group: CardGroup) {
        groupToEdit = group
    }
    
    private func handleDelete(_ group: CardGroup) {
        groupToDelete = group
        showDeleteGroupAlert = true
    }
}
