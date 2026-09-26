//
//  SolveView.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI

struct SolveView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAddFirstCardSheet = false
    
    @State private var viewModel: SolveViewModel
    private let container: AppContainer
    
    init(key: SolveGroupKey, title: String, container: AppContainer) {
        self.container = container
        _viewModel = State(initialValue: SolveViewModel(
            key: key,
            title: title,
            cardRepository: container.cardRepository,
            statsRepository: container.statsRepository,
            sessionCoordinator: container.solveSessionCoordinator,
            achievementsService: container.achievementsService
        ))
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            content
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.onAppear() }
        .sheet(isPresented: $showAddFirstCardSheet) {
            AddFirstCardSheet(
                group: userGroupForCurrentKey,
                systemType: systemTypeForCurrentKey,
                cardRepository: container.cardRepository,
                groupRepository: container.groupRepository,
                onComplete: {
                    viewModel.onAppear()
                }
            )
        }
        .alert(
            "continue_session_question".localized(),
            isPresented: $viewModel.showUnfinishedSessionAlert
        ) {
            Button("start_over".localized()) { viewModel.startOver() }
            Button("continue".localized()) { viewModel.continueSession() }
        } message: {
            Text(String(
                format: "continue_session_message".localized(),
                viewModel.successCount + viewModel.failCount,
                viewModel.totalProgress
            ))
        }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .empty:
            EmptyGroupView(
                groupTitle: viewModel.groupTitle,
                onAddFirstCard: handleAddFirstCard,
                onDismiss: { dismiss() }
            )
        case .completedWithoutMistakes:
            ResultView(
                successCount: viewModel.successCount,
                failCount: viewModel.failCount,
                progressFraction: viewModel.progressFraction,
                hasMistakes: false,
                onRestart: { viewModel.restartFromResult() },
                onRestartMistakes: nil
            )
        case .completedWithMistakes:
            ResultView(
                successCount: viewModel.successCount,
                failCount: viewModel.failCount,
                progressFraction: viewModel.progressFraction,
                hasMistakes: true,
                onRestart: { viewModel.restartFromResult() },
                onRestartMistakes: { viewModel.restartMistakesFromResult() }
            )
        case .solving:
            solvingScreen
        }
    }
    
    // MARK: - Solving screen
    
    private var solvingScreen: some View {
        VStack {
            Text("\(viewModel.currentProgress)/\(viewModel.totalProgress)")
                .font(.titleCustom)
                .foregroundColor(.textSecondary)
            
            AnswerCounterView(
                correctCount: viewModel.successCount,
                wrongCount: viewModel.failCount,
                percentageOfMove: viewModel.percentageOfMove
            )
            
            Spacer()
            
            cardArea
            
            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private var cardArea: some View {
        if let card = viewModel.currentCard {
            SwipeableCardView(
                card: card,
                percentageOfMove: viewModel.percentageOfMove,
                onToggleFavourite: { viewModel.toggleFavouriteCurrentCard() }
            )
            .offset(x: viewModel.offsetOfCardX, y: viewModel.offsetOfCardY)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.offsetOfCardX)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.offsetOfCardY)
            .gesture(dragGesture)
        } else {
            Color.clear
                .frame(width: 320, height: 480)
        }
    }
    
    // MARK: - Gesture
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                viewModel.onDragChanged(value)
            }
            .onEnded { value in
                let decision = viewModel.onDragEnded(value)
                handleDecision(decision)
            }
    }
    
    private func handleDecision(_ decision: SolveViewModel.SwipeDecision) {
        switch decision {
        case .flyLeft:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.offsetOfCardX = -1000
            }
            Task { await viewModel.commitSwipe(.flyLeft) }
        case .flyRight:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.offsetOfCardX = 1000
            }
            Task { await viewModel.commitSwipe(.flyRight) }
        case .reset:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.offsetOfCardX = 0
                viewModel.offsetOfCardY = 0
            }
            Task { await viewModel.commitSwipe(.reset) }
        }
    }
    
    // MARK: - Handlers
    
    private func handleAddFirstCard() {
        showAddFirstCardSheet = true
    }

    // MARK: - Helpers
    
    private var userGroupForCurrentKey: CardGroup? {
        if case .user(let id) = viewModel.key {
            return try? container.groupRepository.fetch(id: id)
        }
        return nil
    }

    private var systemTypeForCurrentKey: SystemGroupType? {
        if case .system(let type) = viewModel.key {
            return type
        }
        return nil
    }
}
