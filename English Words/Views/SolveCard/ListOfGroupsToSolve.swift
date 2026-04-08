//
//  ListOfGroupsToSolve.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct ListOfGroupsToSolve: View {
    @ObservedObject var cardsManager: CardsManager
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(cardsManager.groups) { group in
                        NavigationLink {
                            SolveCardScreenView(cardsManager: cardsManager, curGroup: group.cards)
                        } label: {
                            GroupSolveCard(group: group)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("choose_group".localized())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GroupSolveCard: View {
    let group: CardsGroup
    @ObservedObject var cards: Cards
    
    init(group: CardsGroup) {
        self.group = group
        self._cards = ObservedObject(wrappedValue: group.cards)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(group.displayName)
                .font(.titleCustom)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            if cards.hasUnfinishedSession && !cards.isSessionCompleted {
                HStack(spacing: 4) {
                    Image(systemName: "play.circle.fill")
                        .font(.caption)
                        .foregroundColor(.accent)
                    Text(String(format: "continue_session".localized(), cards.success.count + cards.fail.count, cards.cardsArr.count))
                        .font(.captionCustom)
                        .foregroundColor(.accent)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accent.opacity(0.15))
                .cornerRadius(12)
            } else if cards.checkCurrentState() == .solving {
                if !cards.fail.isEmpty || !cards.success.isEmpty {
                    Text("\(cards.success.count + cards.fail.count)/\(cards.cardsArr.count)")
                        .font(.captionCustom)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .languageAware()
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: .shadowColor, radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke((cards.hasUnfinishedSession && !cards.isSessionCompleted) ? Color.accent : Color.stroke, lineWidth: (cards.hasUnfinishedSession && !cards.isSessionCompleted) ? 2 : 1)
        )
    }
}
