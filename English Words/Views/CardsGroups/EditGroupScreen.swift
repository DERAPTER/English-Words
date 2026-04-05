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
    
    @State private var newGroupName: String = ""
    @State private var isEditingName = false
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
            
            // Изменить название
            VStack(alignment: .leading, spacing: 8) {
                Text("group_name_label".localized())
                    .font(.bodyCustom)
                    .foregroundColor(.textSecondary)
                
                HStack {
                    TextField("enter_new_name".localized(), text: $newGroupName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditingName)
                    
                    Button(action: {
                        if isSystemGroup {
                            systemAlertMessage = "system_group_cannot_rename".localized()
                            showSystemGroupAlert = true
                            return
                        }
                        if isEditingName {
                            if !newGroupName.isEmpty {
                                cardsManager.renameGroup(group, to: newGroupName)
                            }
                            isEditingName = false
                        } else {
                            newGroupName = group.name
                            isEditingName = true
                        }
                    }) {
                        Text(isEditingName ? "save".localized() : "edit".localized())
                            .font(.bodyCustom)
                            .foregroundColor(.accent)
                    }
                }
            }
            .padding(.horizontal)
            
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
                .foregroundColor(.red)
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
            
            Spacer()
        }
        .languageAware()
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("group_settings".localized())
        .navigationBarTitleDisplayMode(.inline)
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
}

// MARK: - StatsRow
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
