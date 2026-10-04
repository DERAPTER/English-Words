//
//  SRSCardView.swift
//  English Words
//
//  Created by Егор Халиков on 04.10.2026.
//

import SwiftUI

/// Карточка для SRS-режима.
/// Отличается от `SwipeableCardView`:
/// - Нет свайпов.
/// - Тап переворачивает карточку.
/// - На лицевой стороне — только слово и подсказка.
/// - На обороте — слово + перевод.
struct SRSCardView: View {
    @Bindable var card: Card
    @Binding var isFlipped: Bool
    let onToggleFavourite: () -> Void
    
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
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
        .onChange(of: card.id) { _, _ in
            isFlipped = false
        }
    }
    
    // MARK: - Sides
    
    private var frontSide: some View {
        cardBase {
            VStack(spacing: 12) {
                Text("srs_tap_to_reveal".localized())
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
                    .padding(.vertical, 6)
                
                Text(card.originWord)
                    .font(.largeTitleCustom)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: 280)
            }
        }
    }
    
    private var backSide: some View {
        cardBase {
            VStack(spacing: 12) {
                Text(card.originWord)
                    .font(.title2)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 20)
                
                Divider()
                    .background(Color.stroke)
                    .padding(.horizontal, 40)
                
                Text(card.translatedWord)
                    .font(.largeTitleCustom)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: 280)
            }
        }
    }
    
    // MARK: - Base
    
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
}
