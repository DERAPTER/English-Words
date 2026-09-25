//
//  AddCardView.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

//
//  AddCardSheet.swift
//  English Words
//

import SwiftUI

struct AddCardSheet: View {
    let group: CardGroup
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Add card to \(group.name)")
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
