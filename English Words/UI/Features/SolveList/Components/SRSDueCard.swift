//
//  SRSDueCard.swift
//  English Words
//
//  Created by Егор Халиков on 04.10.2026.
//

import SwiftUI

/// Верхняя карточка в списке нарешивания — «Повторение сегодня».
/// Показывается, только если есть карточки, due на сегодня.
struct SRSDueCard: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accent.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundColor(.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("srs_review_title".localized())
                    .font(.bodyCustom.weight(.semibold))
                    .foregroundColor(.textPrimary)
                Text(String(format: "srs_due_count".localized(), count))
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Text("\(count)")
                .font(.title2.weight(.bold))
                .foregroundColor(.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.accent.opacity(0.15)))
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.accent, lineWidth: 1.5)
        )
        .shadow(color: .shadowColor, radius: 6, x: 0, y: 2)
    }
}
