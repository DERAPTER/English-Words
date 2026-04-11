//
//  ListOfGroupsScreen.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct ListOfGroupsScreenView: View {
    @ObservedObject var cardsManager: CardsManager
    @State private var showAddGroupSheet = false
    @State private var contentHeight: CGFloat = 0
    @State private var screenHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        VStack{}.frame(height: 6)
                        // Группы
                        ForEach(cardsManager.groups) { group in
                            GroupView(group: group, cardsManager: cardsManager)
                                .padding(.horizontal)
                        }
                        
                        // Добавляем Spacer только если групп мало
                        if groupsFitOnScreen(geometry: geometry) {
                            Spacer(minLength: 0)
                        }
                        
                        // Кнопка добавления новой группы
                        Button(action: { showAddGroupSheet = true }) {
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
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                    }
                    .frame(minHeight: geometry.size.height)
                    .background(
                        GeometryReader { contentGeometry in
                            Color.clear
                                .onAppear {
                                    contentHeight = contentGeometry.size.height
                                    screenHeight = geometry.size.height
                                }
                                .onChange(of: cardsManager.groups.count) { _ in
                                    contentHeight = contentGeometry.size.height
                                }
                        }
                    )
                }
                .scrollDismissesKeyboard(.immediately)
                .scrollIndicators(.hidden)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("groups_title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .id(cardsManager.groups.map { $0.name }.joined())
            .sheet(isPresented: $showAddGroupSheet) {
                AddGroupSheet(cardsManager: cardsManager, isPresented: $showAddGroupSheet)
            }
        }
        .languageAware()
    }
    
    private func groupsFitOnScreen(geometry: GeometryProxy) -> Bool {
        let groupHeight: CGFloat = 80
        let buttonHeight: CGFloat = 120
        let topPadding: CGFloat = 100
        
        let groupsHeight = CGFloat(cardsManager.groups.count) * groupHeight
        let totalHeight = groupsHeight + buttonHeight + topPadding
        
        return totalHeight < geometry.size.height
    }
}

// MARK: - Add Group Sheet
struct AddGroupSheet: View {
    @ObservedObject var cardsManager: CardsManager
    @Binding var isPresented: Bool
    @State private var groupName = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.accent)
                    Text("create_new_group".localized())
                        .font(.largeTitleCustom)
                        .foregroundColor(.textPrimary)
                    Text("add_new_group_description".localized())
                        .font(.bodyCustom)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Поле ввода названия
                VStack(alignment: .leading, spacing: 8) {
                    Text("group_name".localized())
                        .font(.bodyCustom)
                        .foregroundColor(.textSecondary)
                    TextField("enter_group_name".localized(), text: $groupName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.stroke, lineWidth: 1)
                        )
                        .focused($isFocused)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Кнопка создания
                Button(action: createGroup) {
                    Text("create_group".localized())
                        .font(.bodyCustom.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(groupName.isEmpty ? Color.gray : Color.accent)
                        .cornerRadius(16)
                }
                .disabled(groupName.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized()) {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
    
    private func createGroup() {
        guard !groupName.isEmpty else { return }
        cardsManager.addNewGroup(name: groupName)
        isPresented = false
    }
}
