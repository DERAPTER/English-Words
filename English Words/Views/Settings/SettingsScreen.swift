//
//  SettingsScreen.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var cardsManager: CardsManager
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var storageSize: String = "Вычисление..."
    @State private var showReleaseNotesSheet = false
    @State private var showResetStatsAlert = false
    @State private var showDeleteAllAlert = false
    @State private var showLanguageChangeAlert = false
    @State private var pendingLanguage: AppLanguage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 60))
                        .foregroundColor(themeManager.colors.accent)
                    Text("settings_title".localized())
                        .font(.largeTitleCustom)
                        .foregroundColor(themeManager.colors.textPrimary)
                    Text("settings_description".localized())
                        .font(.bodyCustom)
                        .foregroundColor(themeManager.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Секция: Внешний вид
                VStack(alignment: .leading, spacing: 16) {
                    Text("appearance".localized())
                        .font(.titleCustom)
                        .foregroundColor(themeManager.colors.textPrimary)
                        .padding(.horizontal)
                    
                    ThemePickerGridView()
                }
                
                Divider()
                    .background(themeManager.colors.stroke)
                    .padding(.horizontal)
                
                // Секция: Язык (прямо на экране)
                VStack(alignment: .leading, spacing: 16) {
                    Text("language".localized())
                        .font(.titleCustom)
                        .foregroundColor(themeManager.colors.textPrimary)
                        .padding(.horizontal)
                    
                    Text("language_description".localized())
                        .font(.captionCustom)
                        .foregroundColor(themeManager.colors.textSecondary)
                        .padding(.horizontal)
                    
                    // Кнопки выбора языка
                    HStack(spacing: 16) {
                        LanguageButton(
                            language: .english,
                            isSelected: languageManager.currentLanguage == .english,
                            themeManager: themeManager
                        ) {
                            pendingLanguage = .english
                            showLanguageChangeAlert = true
                        }
                        .id("english_\(languageManager.currentLanguage.rawValue)")
                        
                        LanguageButton(
                            language: .russian,
                            isSelected: languageManager.currentLanguage == .russian,
                            themeManager: themeManager
                        ) {
                            pendingLanguage = .russian
                            showLanguageChangeAlert = true
                        }
                        .id("russian_\(languageManager.currentLanguage.rawValue)")
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .background(themeManager.colors.stroke)
                    .padding(.horizontal)
                
                // Секция: Данные
                VStack(alignment: .leading, spacing: 16) {
                    Text("data".localized())
                        .font(.titleCustom)
                        .foregroundColor(themeManager.colors.textPrimary)
                        .padding(.horizontal)
                    
                    SettingsInfoRow(
                        icon: "internaldrive",
                        title: "storage_size".localized(),
                        value: storageSize
                    )
                    
                    SettingsRow(
                        icon: "arrow.counterclockwise",
                        title: "reset_statistics_short".localized(),
                        description: "reset_statistics_description".localized(),
                        color: .orange
                    ) {
                        showResetStatsAlert = true
                    }
                    
                    SettingsRow(
                        icon: "trash",
                        title: "delete_all_data".localized(),
                        description: "delete_all_data_description".localized(),
                        color: .red
                    ) {
                        showDeleteAllAlert = true
                    }
                }
                
                Divider()
                    .background(themeManager.colors.stroke)
                    .padding(.horizontal)
                
                // Секция: О приложении
                VStack(alignment: .leading, spacing: 16) {
                    Text("about".localized())
                        .font(.titleCustom)
                        .foregroundColor(themeManager.colors.textPrimary)
                        .padding(.horizontal)
                    
                    SettingsInfoRow(
                        icon: "info.circle",
                        title: "version".localized(),
                        value: "1.0.2"
                    )
                    
                    SettingsRow(
                        icon: "clock.arrow.circlepath",
                        title: "release_notes".localized(),
                        description: "release_notes_description".localized(),
                        color: themeManager.colors.accent
                    ) {
                        showReleaseNotesSheet = true
                    }
                    
                }
                
                Spacer(minLength: 100)
            }
            .padding(.bottom, 100)
        }
        .languageAware()
        .background(themeManager.colors.background.ignoresSafeArea())
        .navigationTitle("settings_title".localized())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateStorageSize()
        }
        .sheet(isPresented: $showReleaseNotesSheet) {
            ReleaseNotesSheet()
        }
        .alert("reset_statistics_alert_title".localized(), isPresented: $showResetStatsAlert) {
            Button("cancel_button".localized(), role: .cancel) { }
            Button("reset".localized(), role: .destructive) {
                resetStatistics()
            }
        } message: {
            Text("reset_statistics_alert_message".localized())
        }
        .alert("delete_all_alert_title".localized(), isPresented: $showDeleteAllAlert) {
            Button("cancel_button".localized(), role: .cancel) { }
            Button("delete_button".localized(), role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("delete_all_alert_message".localized())
        }
        .alert("change_language_title".localized(), isPresented: $showLanguageChangeAlert) {
            Button("cancel_button".localized(), role: .cancel) {
                pendingLanguage = nil
            }
            Button("change".localized(), role: .destructive) {
                if let language = pendingLanguage {
                    changeLanguage(to: language)
                }
            }
        } message: {
            Text("change_language_message".localized())
        }
    }
    
    private func updateStorageSize() {
        storageSize = DataManager.shared.getStorageSize()
    }
    
    private func resetStatistics() {
        for group in cardsManager.groups {
            group.cards.resetStats()
            group.cards.restartSolve()
        }
        
        cardsManager.streak = 0
        cardsManager.totalSolved = 0
        cardsManager.todaySolvedRaw = 0
        cardsManager.activityHistory = [:]
        
        DataManager.shared.saveData(groups: cardsManager.groups)
        updateStorageSize()
    }
    
    private func deleteAllData() {
        DataManager.shared.clearAllData()
        
        cardsManager.groups.removeAll()
        
        cardsManager.addNewGroup(name: "All Cards")
        cardsManager.addNewGroup(name: "Favourites")
        
        cardsManager.streak = 0
        cardsManager.totalSolved = 0
        cardsManager.todaySolvedRaw = 0
        cardsManager.activityHistory = [:]
        cardsManager.dailyGoal = 20
        
        DataManager.shared.saveData(groups: cardsManager.groups)
    
        updateStorageSize()
        cardsManager.objectWillChange.send()
    }
    
    private func changeLanguage(to language: AppLanguage) {
        languageManager.setLanguage(language)
    }
}

// MARK: - Language Button
struct LanguageButton: View {
    let language: AppLanguage
    let isSelected: Bool
    let themeManager: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(language.flagEmoji)
                    .font(.title2)
                
                Text(language.displayName)
                    .font(.bodyCustom)
                    .foregroundColor(isSelected ? themeManager.colors.accent : themeManager.colors.textPrimary)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(themeManager.colors.accent)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? themeManager.colors.accent.opacity(0.15) : themeManager.colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? themeManager.colors.accent : themeManager.colors.stroke, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Theme Picker Grid View
struct ThemePickerGridView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                ThemeOptionCard(
                    theme: theme,
                    isSelected: themeManager.currentTheme == theme,
                    onSelect: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            themeManager.setTheme(theme)
                        }
                    }
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Theme Option Card
struct ThemeOptionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let onSelect: () -> Void
    
    @ObservedObject private var themeManager = ThemeManager.shared
    
    private var previewColors: [Color] {
        switch theme {
        case .beige:
            return [
                Color(red: 0.96, green: 0.93, blue: 0.88),
                Color(red: 0.94, green: 0.91, blue: 0.86),
                Color(red: 0.8, green: 0.65, blue: 0.45)
            ]
        case .green:
            return [
                Color(hex: "#051F20"),
                Color(hex: "#0B2B26"),
                Color(hex: "#235347")
            ]
        case .blue:
            return [
                Color(hex: "#021024"),
                Color(hex: "#052659"),
                Color(hex: "#548383")
            ]
        case .pink:
            return [
                Color(hex: "#F6E5D0"),
                Color(hex: "#FFDFC3"),
                Color(hex: "#FBA2AB")
            ]
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(previewColors[index])
                            .frame(width: 35, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.8)
                            )
                    }
                }
                .padding(.top, 12)
                
                Text(theme.displayName)
                    .font(.bodyCustom)
                    .foregroundColor(isSelected ? themeManager.colors.accent : themeManager.colors.textSecondary)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(themeManager.colors.accent)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(themeManager.colors.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? themeManager.colors.accent : themeManager.colors.stroke, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.bodyCustom)
                        .foregroundColor(themeManager.colors.textPrimary)
                    Text(description)
                        .font(.captionCustom)
                        .foregroundColor(themeManager.colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(themeManager.colors.textSecondary)
            }
            .padding()
            .background(themeManager.colors.cardBackground)
            .cornerRadius(12)
            .shadow(color: themeManager.colors.shadowColor, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

// MARK: - Settings Info Row
struct SettingsInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeManager.colors.textSecondary)
                .frame(width: 32)
            
            Text(title)
                .font(.bodyCustom)
                .foregroundColor(themeManager.colors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.bodyCustom)
                .foregroundColor(themeManager.colors.textSecondary)
        }
        .padding()
        .background(themeManager.colors.cardBackground)
        .cornerRadius(12)
        .shadow(color: themeManager.colors.shadowColor, radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
