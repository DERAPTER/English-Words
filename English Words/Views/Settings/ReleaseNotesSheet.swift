//
//  ReleaseNotesSheet.swift
//  English Words
//
//  Created by Егор Халиков on 04.04.2026.
//

import SwiftUI

struct ReleaseNotesSheet: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // v1.0.6 - Current
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.accent)
                            Text("version_1_0_6".localized())
                                .font(.titleCustom)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("current_version".localized())
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_6_1".localized())
                        }
                    }
                    
                    // v1.0.5
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("version_1_0_5".localized())
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("previous_version".localized())
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_5_1".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_5_2".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_5_3".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_5_4".localized())
                        }
                    }
                    
                    // v1.0.4
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("version_1_0_4".localized())
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("previous_version".localized())
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_4_1".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_4_2".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_4_3".localized())
                        }
                    }
                    
                    // v1.0.3
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("version_1_0_3".localized())
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("previous_version".localized())
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_3_1".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_3_2".localized())
                        }
                    }
                    
                    // v1.0.2
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("version_1_0_2".localized())
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("previous_version".localized())
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_2_1".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_2_2".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_2_3".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_2_4".localized())
                        }
                    }
                    
                    // v1.0.1
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("version_1_0_1".localized())
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("previous_version".localized())
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_1_1".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_1_2".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_1_3".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_1_4".localized())
                        }
                    }
                    
                    // v1.0.0 - Initial release
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "flag.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("version_1_0_0".localized())
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("initial_release".localized())
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_1".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_2".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_3".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_4".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_5".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_6".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_7".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_8".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_9".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_10".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_11".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_12".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_13".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_14".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_15".localized())
                            ReleaseNoteItem(icon: "plus.circle", text: "release_notes_1_0_0_16".localized())
                        }
                    }
                }
                .padding()
            }
            .background(themeManager.colors.background.ignoresSafeArea())
            .navigationTitle("release_notes".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close_button".localized()) {
                        dismiss()
                    }
                    .foregroundColor(themeManager.colors.accent)
                }
            }
        }
    }
}

// MARK: - Release Note Item
struct ReleaseNoteItem: View {
    let icon: String
    let text: String
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(themeManager.colors.accent)
                .frame(width: 20)
            
            Text(text)
                .font(.bodyCustom)
                .foregroundColor(themeManager.colors.textPrimary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ReleaseNotesSheet()
}
