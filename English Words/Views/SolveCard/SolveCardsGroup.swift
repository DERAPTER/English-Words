//
//  SolveCardsGroup.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

enum SolvingCardCases {
    case solving
    case fullRestart
    case mistakesRestart
    case error
}

struct SolveCardsGroup: View {
    @ObservedObject var cardsManager: CardsManager
    @ObservedObject var cards: Cards
    
    @State var isFirstEnter: Bool = true
    @State var offsetOfCardX: CGFloat = 0
    @State var offsetOfCardY: CGFloat = 0
    @State var percentageOfMove: Double = 0
    @State var showAlertToSolveMistakes = false
    
    @State private var showUnfinishedSessionAlert = false
    @State private var hasCheckedSession = false
    
    var curSolvingState: SolvingCardCases {
        cards.checkCurrentState()
    }
    
    var currentCard: Card {
        cards.curCard ?? Card(origin: "No cards", translate: "No cards")
    }
    
    var percentageOfCorrect: Int {
        Int(cards.progressFraction * 100)
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            Group {
                switch curSolvingState {
                case .solving:
                    solvingScreen
                case .fullRestart:
                    ResultView(
                        cards: cards,
                        hasMistakes: false,
                        onRestart: { cards.restartSolve() },
                        onRestartMistakes: nil
                    )
                case .mistakesRestart:
                    ResultView(
                        cards: cards,
                        hasMistakes: true,
                        onRestart: { cards.restartSolve() },
                        onRestartMistakes: { cards.restartSolveWithMistakes() }
                    )
                case .error:
                    Text("ERROR")
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .onAppear {
            if !cards.hasAppeared {
                // Показываем алерт только если есть незавершённая сессия И сессия не завершена
                if cards.hasUnfinishedSession && !cards.isSessionCompleted && !hasCheckedSession {
                    showUnfinishedSessionAlert = true
                } else if !cards.hasUnfinishedSession {
                    cards.restartSolve()
                }
                cards.hasAppeared = true
                hasCheckedSession = true
            }
        }
        .alert("continue_session_question".localized(), isPresented: $showUnfinishedSessionAlert) {
            Button("start_over".localized()) {
                cards.restartSolve()
            }
            Button("continue".localized()) {
                cards.continueSession()
            }
        } message: {
            Text(String(format: "continue_session_message".localized(), cards.success.count + cards.fail.count, cards.cardsArr.count))
        }
    }
    
    // MARK: - Solving Screen
    private var solvingScreen: some View {
        VStack {
            Text("\(cards.curIndexPublic)/\(cards.curMaxIndexPublic)")
                .font(.titleCustom)
                .foregroundColor(.textSecondary)
            
            counterCorrectsAndMistakes
            
            Spacer()
            
            CardView(
                cardsManager: cardsManager,
                card: currentCard,
                percentageOfMove: percentageOfMove
            )
            .offset(x: offsetOfCardX, y: offsetOfCardY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        handleSwipe(value: value, card: currentCard)
                    }
                    .onEnded { value in
                        handleSwipeEnd(value: value, card: currentCard)
                    }
            )
            
            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
        .padding(.top, 20)
    }
    
    // MARK: - Counter Views
    private var counterCorrectsAndMistakes: some View {
        HStack {
            counterMistakes
            Spacer()
            counterCorrects
        }
        .padding(.horizontal)
    }
    
    private var counterMistakes: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 90, height: 60)
                .foregroundColor(.cardBackground)
                .shadow(color: .shadowColor, radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.wrong, lineWidth: 2)
                )
            Text(" \(cards.fail.count)")
                .font(.bodyCustom)
                .foregroundColor(.textPrimary)
                .offset(x: 5)
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: 90, height: 60)
                    .foregroundColor(.wrong)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.wrong, lineWidth: 2)
                    )
                Text("+1")
                    .font(.bodyCustom)
                    .foregroundColor(.white)
                    .offset(x: 5)
            }
            .opacity(findWrongOpacity(percentage: percentageOfMove))
            .animation(.easeInOut(duration: 0.3), value: percentageOfMove)
        }
        .offset(x: -45)
    }
    
    private func findCorrectOpacity(percentage: Double) -> Double {
        percentage > 0 ? percentage : 0
    }
    
    private func findWrongOpacity(percentage: Double) -> Double {
        percentage < 0 ? -percentage : 0
    }
    
    private var counterCorrects: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 90, height: 60)
                .foregroundColor(.cardBackground)
                .shadow(color: .shadowColor, radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.correct, lineWidth: 2)
                )
            Text("\(cards.success.count)")
                .font(.bodyCustom)
                .foregroundColor(.textPrimary)
                .offset(x: -5)
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: 90, height: 60)
                    .foregroundColor(.correct)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.correct, lineWidth: 2)
                    )
                Text("+1")
                    .font(.bodyCustom)
                    .foregroundColor(.white)
                    .offset(x: -5)
            }
            .opacity(findCorrectOpacity(percentage: percentageOfMove))
            .animation(.easeInOut(duration: 0.3), value: percentageOfMove)
        }
        .offset(x: 45)
    }
    
    // MARK: - Swipe Logic
    func handleSwipe(value: DragGesture.Value, card: Card) {
        let translation = value.translation.width
        let translationY = value.translation.height
        
        offsetOfCardX = translation
        offsetOfCardY = translationY
        
        if translation < -50 {
            percentageOfMove = max(-1, (translation + 50) / 100)
        } else if translation > 50 {
            percentageOfMove = min(1, (translation - 50) / 100)
        }
    }
    
    func handleSwipeEnd(value: DragGesture.Value, card: Card) {
        let translation = value.translation.width
        let predictedEnd = value.predictedEndTranslation.width
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offsetOfCardY = 0
        }
        
        if translation < -100 || predictedEnd < -100 {
            percentageOfMove = 0
            leftSwipe()
        } else if translation > 100 || predictedEnd > 100 {
            percentageOfMove = 0
            rightSwipe()
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                offsetOfCardX = 0
                percentageOfMove = 0
            }
        }
    }
    
    func leftSwipe() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offsetOfCardX = -1000
        }
        cards.solveFail(card: currentCard)
        DataManager.shared.saveData(groups: cardsManager.groups)
        offsetOfCardX = 0
    }
    
    func rightSwipe() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offsetOfCardX = 1000
        }
        cards.solveSuccess(card: currentCard)
        cardsManager.recordSolvedCard()
        DataManager.shared.saveData(groups: cardsManager.groups)
        offsetOfCardX = 0
    }
}

// MARK: - ResultView
struct ResultView: View {
    @ObservedObject var cards: Cards
    let hasMistakes: Bool
    let onRestart: () -> Void
    let onRestartMistakes: (() -> Void)?
    
    var percentageOfCorrect: Int {
        Int(cards.progressFraction * 100)
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: 40)
            
            VStack(spacing: 16) {
                Text("your_progress".localized())
                    .font(.titleCustom)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                progressCircle
                    .padding(.vertical, 4)
                
                VStack(spacing: 12) {
                    StatRow(label: "know".localized(), count: cards.success.count, color: .correct)
                    StatRow(label: "still_learning_short".localized(), count: cards.fail.count, color: .wrong)
                }
                .padding(.top, 8)
                
                if hasMistakes {
                    VStack(spacing: 12) {
                        Button(action: { onRestartMistakes?() }) {
                            Text("repeat_mistakes".localized())
                                .font(.bodyCustom.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 14)
                                .background(Color.accent)
                                .cornerRadius(25)
                        }
                        
                        Button(action: onRestart) {
                            Text("start_over_button".localized())
                                .font(.bodyCustom.weight(.semibold))
                                .foregroundColor(.accent)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 14)
                                .background(Color.cardBackground)
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.accent, lineWidth: 1)
                                )
                        }
                    }
                } else {
                    Button(action: onRestart) {
                        Text("start_over_button".localized())
                            .font(.bodyCustom.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 14)
                            .background(Color.accent)
                            .cornerRadius(25)
                    }
                }
            }
            .padding(24)
            .background(Color.cardBackground)
            .cornerRadius(30)
            .shadow(color: .shadowColor, radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
            
            Spacer(minLength: 40)
        }
    }
    
    private var progressCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.stroke, lineWidth: 25)
                .frame(width: 180, height: 180)
            
            Circle()
                .trim(from: 0, to: cards.progressFraction)
                .stroke(Color.accent, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 180, height: 180)
            
            if percentageOfCorrect == 100 {
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.accent)
            } else {
                Text("\(percentageOfCorrect)%")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.textPrimary)
            }
        }
    }
}

struct StatRow: View {
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.title3)
                .foregroundColor(.textSecondary)
            Spacer()
            Text("\(count)")
                .font(.title2.weight(.bold))
                .foregroundColor(color)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
