//
//  EditGroupScreen.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct EditGroupScreen: View {
    
    @ObservedObject var cardsManager: CardsManager
    var group: CardsGroup
    
    @State private var groupName: String = ""
    @State private var showDeleteConfirmation = false
    @State private var showResetConfirmation = false
    
    @State private var showSystemGroupAlert = false
    @State private var systemAlertMessage = ""
    
    private var isSystemGroup: Bool {
        cardsManager.isSystemGroup(group)
    }
    
    private var averageProgressAllTime: Double {
        group.cards.resultOfAllTime
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Заголовок
            Text(group.name)
                .font(.largeTitleCustom)
                .foregroundColor(.textPrimary)
                .padding(.top, 20)
            
            // Изменить название (НОВОЕ: всегда активное поле для ввода)
            VStack(alignment: .leading, spacing: 8) {
                Text("group_name_label".localized())
                    .font(.bodyCustom)
                    .foregroundColor(.textSecondary)
                
                if isSystemGroup {
                    // Для системных групп — только для чтения
                    Text(group.name)
                        .font(.bodyCustom)
                        .foregroundColor(.textPrimary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.stroke, lineWidth: 1)
                        )
                    
                    Text("system_group_cannot_rename".localized())
                        .font(.captionCustom)
                        .foregroundColor(.textSecondary)
                        .padding(.leading, 4)
                } else {
                    // Для обычных групп — активное текстовое поле
                    TextField("enter_group_name".localized(), text: $groupName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.stroke, lineWidth: 1)
                        )
                        .onSubmit {
                            saveGroupName()
                        }
                    
                    // Индикатор изменений и кнопка сохранения
                    if groupName != group.name && !groupName.isEmpty {
                        HStack {
                            Text("unsaved_changes".localized())
                                .font(.captionCustom)
                                .foregroundColor(.accent)
                            
                            Spacer()
                            
                            Button(action: saveGroupName) {
                                Text("save".localized())
                                    .font(.captionCustom)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color.accent)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 4)
                        .transition(.opacity)
                    }
                }
            }
            .padding(.horizontal)
            .animation(.easeInOut, value: groupName != group.name)
            
            // Средний процент прохождения за всё время
            StatsRow(title: "average_progress_all_time".localized(),
                    value: "\(Int(averageProgressAllTime * 100))%",
                    color: .accent)
                .padding(.horizontal)
            
            // Сброс данных о прохождениях
            Button(action: { showResetConfirmation = true }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title2)
                    Text("reset_statistics".localized())
                        .font(.bodyCustom)
                }
                .foregroundColor(.orange)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.stroke, lineWidth: 1)
                )
            }
            .padding(.horizontal)
            
            // Удалить группу
            Button(action: {
                if isSystemGroup {
                    systemAlertMessage = "system_group_cannot_delete".localized()
                    showSystemGroupAlert = true
                } else {
                    showDeleteConfirmation = true
                }
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .font(.title2)
                    Text("delete_group".localized())
                        .font(.bodyCustom)
                }
                .foregroundColor(isSystemGroup ? .gray : .red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.stroke, lineWidth: 1)
                )
            }
            .disabled(isSystemGroup)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("group_settings".localized())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            groupName = group.name
        }
        .alert("reset_statistics_confirmation".localized(), isPresented: $showResetConfirmation) {
            Button("cancel".localized(), role: .cancel) { }
            Button("reset".localized(), role: .destructive) {
                group.cards.resetStats()
            }
        } message: {
            Text("reset_statistics_message".localized())
        }
        .alert("delete_group_confirmation".localized(), isPresented: $showDeleteConfirmation) {
            Button("cancel".localized(), role: .cancel) { }
            Button("delete".localized(), role: .destructive) {
                cardsManager.deleteGroup(group)
            }
        } message: {
            Text("delete_group_message".localized())
        }
        .alert("system_group".localized(), isPresented: $showSystemGroupAlert) {
            Button("ok".localized(), role: .cancel) { }
        } message: {
            Text(systemAlertMessage)
        }
    }
    
    // MARK: - Actions
    private func saveGroupName() {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Проверка на пустое имя
        guard !trimmedName.isEmpty else {
            groupName = group.name
            return
        }
        
        // Проверка на дубликат имени
        if cardsManager.groups.contains(where: { $0.name == trimmedName && $0.id != group.id }) {
            systemAlertMessage = "group_name_already_exists".localized()
            showSystemGroupAlert = true
            groupName = group.name
            return
        }
        
        // Сохраняем новое имя
        cardsManager.renameGroup(group, to: trimmedName)
        
        // Обновляем локальное состояние
        groupName = trimmedName
    }
}

// MARK: - StatsRow (без изменений)
struct StatsRow: View {
    let title: String
    let value: String
    let color: Color
    
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
        .shadow(color: .shadowColor, radius: 4, x: 0, y: 2)
    }
}
