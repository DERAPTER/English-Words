//
//  SRSResultView.swift
//  English Words
//
//  Created by Егор Халиков on 04.10.2026.
//

import SwiftUI

/// Экран завершения SRS-сессии.
/// Отличается от обычного `ResultView`: нет «повторить ошибки»,
/// потому что все карточки уже получили новое расписание.
struct SRSResultView: View {
    let reviewedCount: Int
    let onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.accent)
            
            Text("srs_result_title".localized())
                .font(.largeTitleCustom)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(String(format: "srs_result_message".localized(), reviewedCount))
                .font(.bodyCustom)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: onFinish) {
                Text("close".localized())
                    .font(.bodyCustom.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accent)
                    .cornerRadius(16)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}
