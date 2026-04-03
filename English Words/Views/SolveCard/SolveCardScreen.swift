//
//  SolveCardScreen.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct SolveCardScreenView: View {
    @ObservedObject var cardsManager: CardsManager
    @State var curGroup: Cards

    var body: some View {
        SolveCardsGroup(cardsManager: cardsManager, cards: curGroup)
            .background(Color.appBackground.ignoresSafeArea())
    }
}
