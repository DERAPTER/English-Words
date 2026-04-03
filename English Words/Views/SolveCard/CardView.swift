//
//  CardView.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct CardView: View {
    @ObservedObject var cardsManager: CardsManager
    @ObservedObject var card: Card
    var percentageOfMove: Double
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            frontView.opacity(isFlipped ? 0 : 1)
            backView.opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .overlay(
            ZStack {
                // Зелёная обводка (правильно)
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.correct, lineWidth: 4)
                    .opacity(percentageOfMove > 0 ? percentageOfMove : 0)
                
                // Красная обводка (неправильно)
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.wrong, lineWidth: 4)
                    .opacity(percentageOfMove < 0 ? -percentageOfMove : 0)
                
                
            }
        )
        .onTapGesture {
            withAnimation(.spring()) {
                isFlipped.toggle()
            }
        }
        .onChange(of: card) {
            isFlipped = false
        }
    }
    
    var frontView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.cardBackground)
                .frame(width: 300, height: 450)
                .shadow(color: .shadowColor, radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.stroke, lineWidth: 1)
                )
            VStack {
                // Текст "Уже знаю"
                if percentageOfMove > 0 {
                    Text("Уже знаю")
                        .font(.title2.bold())
                        .foregroundColor(.correct)
                        .padding(8)
                        .background(Color.cardBackground.opacity(0.9))
                        .cornerRadius(12)
                        //.position(x: 220, y: 120)
                        .opacity(percentageOfMove)
                }
                
                // Текст "Ещё изучаю"
                if percentageOfMove < 0 {
                    Text("Ещё изучаю")
                        .font(.title2.bold())
                        .foregroundColor(.wrong)
                        .padding(8)
                        .background(Color.cardBackground.opacity(0.9))
                        .cornerRadius(12)
                        //.position(x: 80, y: 120)
                        .opacity(-percentageOfMove)
                }
                
                Text(card.originWord)
                    .font(.largeTitleCustom)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(min(1-findWrongOpacity(percentage: percentageOfMove), 1-findCorrectOpacity(percentage: percentageOfMove)))
            }
        }
        .overlay(
            Button(action: { cardsManager.toggleCardFromFavourite(card: card) }) {
                Image(systemName: card.isFavourite ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundColor(card.isFavourite ? .accent : .textSecondary)
            }
            .padding(16),
            alignment: .topTrailing
        )
    }
    
    var backView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.cardBackground)
                .frame(width: 300, height: 450)
                .shadow(color: .shadowColor, radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.stroke, lineWidth: 1)
                )
            VStack {
                // Текст "Уже знаю"
                if percentageOfMove > 0 {
                    Text("Уже знаю")
                        .font(.title2.bold())
                        .foregroundColor(.correct)
                        .padding(8)
                        .background(Color.cardBackground.opacity(0.9))
                        .cornerRadius(12)
                        //.position(x: 220, y: 120)
                        .opacity(percentageOfMove)
                }
                
                // Текст "Ещё изучаю"
                if percentageOfMove < 0 {
                    Text("Ещё изучаю")
                        .font(.title2.bold())
                        .foregroundColor(.wrong)
                        .padding(8)
                        .background(Color.cardBackground.opacity(0.9))
                        .cornerRadius(12)
                        //.position(x: 80, y: 120)
                        .opacity(-percentageOfMove)
                }
                
                Text(card.translatedWord)
                    .font(.largeTitleCustom)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(min(1-findWrongOpacity(percentage: percentageOfMove), 1-findCorrectOpacity(percentage: percentageOfMove)))
            }
        }
        .overlay(
            Button(action: { cardsManager.toggleCardFromFavourite(card: card) }) {
                Image(systemName: card.isFavourite ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundColor(card.isFavourite ? .accent : .textSecondary)
            }
            .padding(16),
            alignment: .topTrailing
        )
    }
    
    private func findCorrectOpacity(percentage: Double) -> Double {
        if percentage > 0 {
            return percentage
        }
        return 0
    }
    
    private func findWrongOpacity(percentage: Double) -> Double {
        if percentage < 0 {
            return -1 * percentage
        }
        return 0
    }
    
}
