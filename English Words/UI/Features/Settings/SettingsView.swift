//
//  SettingsView.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppContainer.self) private var container
    
    private let themeManager = ThemeManager.shared
    private let languageManager = LanguageManager.shared
    
    @State private var viewModel: SettingsViewModel
    
    @AppStorage("srsNewCardsPerDay") private var srsNewCardsLimit: Int = 20
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    
    init(container: AppContainer) {
        _viewModel = State(initialValue: SettingsViewModel(
            cardRepository: container.cardRepository,
            groupRepository: container.groupRepository,
            statsRepository: container.statsRepository,
            solveSessionStore: container.solveSessionStore
        ))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                header
                
                appearanceSection
                
                divider
                
                srsSection
                
                divider
                
                feedbackSection
                
                divider
                
                languageSection
                
                divider
                
                dataSection
                
                divider
                
                aboutSection
                
                Spacer(minLength: 60)
            }
            .padding(.bottom, 100)
        }
        .background(themeManager.colors.background.ignoresSafeArea())
        .navigationTitle("settings_title".localized())
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.updateStorageSize()
        }
        .onAppear {
            viewModel.updateStorageSize()
        }
        .sheet(isPresented: $viewModel.showReleaseNotesSheet) {
            ReleaseNotesSheet()
        }
        .alert(
            "reset_statistics_alert_title".localized(),
            isPresented: $viewModel.showResetStatsAlert
        ) {
            Button("cancel_button".localized(), role: .cancel) { }
            Button("reset".localized(), role: .destructive) {
                viewModel.resetStatistics()
            }
        } message: {
            Text("reset_statistics_alert_message".localized())
        }
        .alert(
            "delete_all_alert_title".localized(),
            isPresented: $viewModel.showDeleteAllAlert
        ) {
            Button("cancel_button".localized(), role: .cancel) { }
            Button("delete_button".localized(), role: .destructive) {
                viewModel.deleteAllData()
            }
        } message: {
            Text("delete_all_alert_message".localized())
        }
        .alert(
            "change_language_title".localized(),
            isPresented: $viewModel.showLanguageChangeAlert
        ) {
            Button("cancel_button".localized(), role: .cancel) {
                viewModel.cancelLanguageChange()
            }
            Button("change".localized(), role: .destructive) {
                viewModel.confirmLanguageChange()
            }
        } message: {
            Text("change_language_message".localized())
        }
        .alert(
            "error_title".localized(),
            isPresented: .constant(viewModel.errorMessage != nil)
        ) {
            Button("ok".localized(), role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Sections
    
    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 60))
                .foregroundColor(.accent)
            Text("settings_title".localized())
                .font(.largeTitleCustom)
                .foregroundColor(.textPrimary)
            Text("settings_description".localized())
                .font(.bodyCustom)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("appearance".localized())
            ThemePickerGridView()
        }
    }
    
    private var srsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("srs_section_title".localized())
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("srs_new_cards_limit".localized())
                        .font(.bodyCustom)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text("\(srsNewCardsLimit)")
                        .font(.bodyCustom.weight(.semibold))
                        .foregroundColor(.accent)
                }
                Slider(
                    value: Binding(
                        get: { Double(srsNewCardsLimit) },
                        set: { srsNewCardsLimit = Int($0) }
                    ),
                    in: 5...100,
                    step: 5
                )
                .tint(.accent)
                
                Text("srs_new_cards_limit_hint".localized())
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("feedback_section".localized())
            
            HStack(spacing: 12) {
                Image(systemName: "hand.tap.fill")
                    .font(.title2)
                    .foregroundColor(.accent)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("haptics_enabled".localized())
                        .font(.bodyCustom)
                        .foregroundColor(.textPrimary)
                    Text("haptics_enabled_description".localized())
                        .font(.captionCustom)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $hapticsEnabled)
                    .labelsHidden()
                    .tint(.accent)
                    .onChange(of: hapticsEnabled) { _, isOn in
                        // Дать пользователю почувствовать эффект при включении.
                        // При выключении отклик уже отключён — тишина.
                        if isOn {
                            HapticService.shared.lightImpact()
                        }
                    }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("language".localized())
            
            Text("language_description".localized())
                .font(.captionCustom)
                .foregroundColor(.textSecondary)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                LanguageButton(
                    language: .english,
                    isSelected: languageManager.currentLanguage == .english
                ) {
                    viewModel.requestLanguageChange(to: .english)
                }
                
                LanguageButton(
                    language: .russian,
                    isSelected: languageManager.currentLanguage == .russian
                ) {
                    viewModel.requestLanguageChange(to: .russian)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("data".localized())
            
            SettingsInfoRow(
                icon: "internaldrive",
                title: "storage_size".localized(),
                value: viewModel.storageSize
            )
            
            SettingsRow(
                icon: "arrow.counterclockwise",
                title: "reset_statistics_short".localized(),
                description: "reset_statistics_description".localized(),
                color: .orange
            ) {
                viewModel.showResetStatsAlert = true
            }
            
            SettingsRow(
                icon: "trash",
                title: "delete_all_data".localized(),
                description: "delete_all_data_description".localized(),
                color: .red
            ) {
                viewModel.showDeleteAllAlert = true
            }
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("about".localized())
            
            SettingsInfoRow(
                icon: "info.circle",
                title: "version".localized(),
                value: appVersion
            )
            
            SettingsInfoRow(
                icon: "person",
                title: "developer".localized(),
                value: "tg: @DERAPTER"
            )
            
            SettingsRow(
                icon: "clock.arrow.circlepath",
                title: "release_notes".localized(),
                description: "release_notes_description".localized(),
                color: .accent
            ) {
                viewModel.showReleaseNotesSheet = true
            }
        }
    }
    
    private var divider: some View {
        Divider()
            .background(Color.stroke)
            .padding(.horizontal)
    }
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.titleCustom)
            .foregroundColor(.textPrimary)
            .padding(.horizontal)
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1.1"
    }
}
