//
//  CardInListView.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct CardInListView: View {
    @ObservedObject var card: Card
    @ObservedObject var cardsManager: CardsManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.originWord)
                    .font(.bodyCustom)
                    .foregroundColor(.textPrimary)
                Text(card.translatedWord)
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
            }
            Spacer()
            Button(action: {
                withAnimation{
                    cardsManager.toggleCardFromFavourite(card: card)
                }
            }) {
                Image(systemName: card.isFavourite ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(card.isFavourite ? .accent : .textSecondary)
            }
            //.padding(16),
            //alignment: .topTrailing
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.cardBackground)
        .cornerRadius(10)
        .shadow(color: .shadowColor, radius: 4, x: 0, y: 1)
    }
}
