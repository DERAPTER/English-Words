//
//  DayDetailSheet.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI

struct DayDetailSheet: View {
    let date: Date
    let isActive: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 80))
                    .foregroundColor(isActive ? .accent : .gray)
                
                Text(formattedDate)
                    .font(.largeTitleCustom)
                    .foregroundColor(.textPrimary)
                
                Text(isActive
                     ? "you_studied_on_this_day".localized()
                     : "no_study_on_this_day".localized())
                .font(.bodyCustom)
                .foregroundColor(isActive ? .accent : .textSecondary)
                .multilineTextAlignment(.center)
                
                Text(isActive
                     ? "keep_it_up".localized()
                     : "start_learning_today".localized())
                .font(.captionCustom)
                .foregroundColor(.textSecondary)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
            .padding()
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close".localized()) { dismiss() }
                }
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = LanguageManager.shared.currentLanguage.locale
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date).capitalized
    }
}

extension Date: @retroactive Identifiable {
    public var id: TimeInterval { timeIntervalSince1970 }
}
