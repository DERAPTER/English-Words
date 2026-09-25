//
//  SwipeableCardView.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI

struct SwipeableCardView: View {
    @Bindable var card: Card
    let percentageOfMove: Double
    let onToggleFavourite: () -> Void
    
    @State private var isFlipped = false
    
    private let cardWidth: CGFloat = 320
    private let cardHeight: CGFloat = 480
    
    var body: some View {
        ZStack {
            frontSide
                .opacity(isFlipped ? 0 : 1)
            backSide
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .frame(width: cardWidth, height: cardHeight)
        .overlay(strokeOverlay)
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
        .onChange(of: card.id) { _, _ in
            isFlipped = false
        }
    }
    
    // MARK: - Front
    
    private var frontSide: some View {
        cardBase {
            VStack(spacing: 16) {
                swipeHintView
                cardWord(card.originWord)
            }
        }
    }
    
    // MARK: - Back
    
    private var backSide: some View {
        cardBase {
            VStack(spacing: 16) {
                swipeHintView
                cardWord(card.translatedWord)
            }
        }
    }
    
    // MARK: - Building blocks
    
    private func cardBase<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.cardBackground)
                .shadow(color: .shadowColor, radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.stroke, lineWidth: 1)
                )
            
            content()
            
            // Кнопка избранного
            VStack {
                HStack {
                    Spacer()
                    Button(action: onToggleFavourite) {
                        Image(systemName: card.isFavourite ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(card.isFavourite ? .accent : .textSecondary)
                            .padding(16)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
    }
    
    private var swipeHintView: some View {
        ZStack {
            if percentageOfMove > 0 {
                hintText("already_know".localized(), color: .correct, opacity: percentageOfMove)
            }
            if percentageOfMove < 0 {
                hintText("still_learning".localized(), color: .wrong, opacity: -percentageOfMove)
            }
        }
        .frame(height: 50)
    }
    
    private func hintText(_ text: String, color: Color, opacity: Double) -> some View {
        Text(text)
            .font(.title2.bold())
            .foregroundColor(color)
            .padding(8)
            .background(Color.cardBackground.opacity(0.9))
            .cornerRadius(12)
            .opacity(opacity)
    }
    
    private func cardWord(_ text: String) -> some View {
        Text(text)
            .font(.largeTitleCustom)
            .foregroundColor(.textPrimary)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 20)
            .frame(maxWidth: 280)
            .opacity(cardTextOpacity)
    }
    
    private var cardTextOpacity: Double {
        let fade = max(abs(percentageOfMove), 0)
        return max(1 - fade, 0)
    }
    
    private var strokeOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.correct, lineWidth: 4)
                .opacity(percentageOfMove > 0 ? percentageOfMove : 0)
            
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.wrong, lineWidth: 4)
                .opacity(percentageOfMove < 0 ? -percentageOfMove : 0)
        }
    }
}
