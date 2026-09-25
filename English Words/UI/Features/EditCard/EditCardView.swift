//
//  EditCardView.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI

struct EditCardView: View {
    let card: Card
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(card.originWord)
                    .font(.titleCustom)
                    .foregroundColor(.textPrimary)
                Text("В разработке")
                    .font(.bodyCustom)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close".localized()) { dismiss() }
                }
            }
        }
    }
}
