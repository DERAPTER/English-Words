//
//  ProfileScreen.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct ProfileScreen: View {
    @ObservedObject var cardsManager: CardsManager
    @StateObject private var achievementsManager = AchievementsManager.shared
    @State private var showingGoalEditor = false
    @State private var tempGoal: Int = 20
    @State private var isStatisticsExpanded = false
    @State private var isCalendarExpanded = false
    @State private var isAchievementsExpanded = false
    @State private var showAllAchievements = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Аватар и имя
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.accent)
                        Text("Learner")
                            .font(.titleCustom)
                            .foregroundColor(.textPrimary)
                    }
                    .padding(.top, 20)
                    
                    // Улучшенная секция цели и серии
                    Button(action: {
                        tempGoal = cardsManager.dailyGoal
                        showingGoalEditor = true
                    }) {
                        VStack(spacing: 20) {
                            Text("your_progress_today".localized())
                                .font(.titleCustom)
                                .foregroundColor(.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(alignment: .center, spacing: 20) {
                                EnhancedStreakView(streak: cardsManager.streak)
                                
                                Spacer()
                                
                                Rectangle()
                                    .fill(Color.stroke)
                                    .frame(width: 1, height: 80)
                                
                                Spacer()
                                
                                EnhancedDailyGoalView(
                                    goal: cardsManager.dailyGoal,
                                    solved: cardsManager.todaySolved,
                                    progress: cardsManager.dailyProgress
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("goal_progress".localized())
                                        .font(.bodyCustom)
                                        .foregroundColor(.textSecondary)
                                    
                                    Spacer()
                                    
                                    Text("\(cardsManager.todaySolved)/\(cardsManager.dailyGoal)")
                                        .font(.bodyCustom.weight(.semibold))
                                        .foregroundColor(.accent)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.stroke.opacity(0.3))
                                            .frame(height: 12)
                                            .cornerRadius(6)
                                        
                                        Rectangle()
                                            .fill(Color.accent)
                                            .frame(width: geometry.size.width * cardsManager.dailyProgress, height: 12)
                                            .cornerRadius(6)
                                    }
                                }
                                .frame(height: 12)
                                
                                if cardsManager.dailyProgress < 0.3 {
                                    Text(String(format: "left_to_goal".localized(), cardsManager.dailyGoal - cardsManager.todaySolved))
                                        .font(.captionCustom)
                                        .foregroundColor(.textSecondary)
                                } else if cardsManager.dailyProgress < 0.7 {
                                    Text("halfway_to_goal".localized())
                                        .font(.captionCustom)
                                        .foregroundColor(.textSecondary)
                                } else if cardsManager.dailyProgress < 1 {
                                    Text("almost_there".localized())
                                        .font(.captionCustom)
                                        .foregroundColor(.textSecondary)
                                } else {
                                    Text("congrats_goal_completed".localized())
                                        .font(.captionCustom)
                                        .foregroundColor(.accent)
                                }
                            }
                            
                            HStack {
                                Image(systemName: "hand.tap")
                                    .font(.caption2)
                                Text("tap_to_change_goal".localized())
                                    .font(.caption2)
                            }
                            .foregroundColor(.accent)
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: .shadowColor, radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    Divider()
                        .background(Color.stroke)
                        .padding(.horizontal)
                    
                    // Календарь активности
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isCalendarExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Text("activity_calendar".localized())
                                    .font(.titleCustom)
                                    .foregroundColor(.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.body)
                                    .foregroundColor(.textSecondary)
                                    .rotationEffect(.degrees(isCalendarExpanded ? 180 : 0))
                            }
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if isCalendarExpanded {
                            ActivityCalendarView(cardsManager: cardsManager)
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                    
                    Divider()
                        .background(Color.stroke)
                        .padding(.horizontal)
                    
                    // Общая статистика
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isStatisticsExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Text("statistics".localized())
                                    .font(.titleCustom)
                                    .foregroundColor(.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.body)
                                    .foregroundColor(.textSecondary)
                                    .rotationEffect(.degrees(isStatisticsExpanded ? 180 : 0))
                            }
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if isStatisticsExpanded {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                StatCard(title: "total_cards".localized(), value: "\(cardsManager.totalCardsCount)")
                                StatCard(title: "groups_count".localized(), value: "\(cardsManager.groups.count)")
                                StatCard(title: "favorites".localized(), value: "\(cardsManager.favouritesCount)")
                                StatCard(title: "total_solved".localized(), value: "\(cardsManager.totalSolved)")
                                StatCard(title: "achievements_unlocked".localized(), value: "\(achievementsManager.achievements.filter { $0.isUnlocked }.count)/\(achievementsManager.achievements.count)")
                            }
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                    
                    Divider()
                        .background(Color.stroke)
                        .padding(.horizontal)
                    
                    // Достижения
                    VStack(alignment: .leading, spacing: 16) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isAchievementsExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Text("achievements".localized())
                                    .font(.titleCustom)
                                    .foregroundColor(.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.body)
                                    .foregroundColor(.textSecondary)
                                    .rotationEffect(.degrees(isAchievementsExpanded ? 180 : 0))
                            }
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if isAchievementsExpanded {
                            // Последние 5 полученных достижений
                            let unlockedAchievements = achievementsManager.achievements.filter { $0.isUnlocked }
                            
                            if !unlockedAchievements.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(unlockedAchievements.prefix(10)) { achievement in
                                            AchievementBadge(
                                                icon: achievement.icon,
                                                title: achievement.title,
                                                unlocked: true
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                                .padding(.horizontal)
                            } else {
                                Text("no_achievements_yet".localized())
                                    .font(.bodyCustom)
                                    .foregroundColor(.textSecondary)
                                    .padding(.horizontal)
                            }
                            
                            // Кнопка "Все достижения"
                            Button(action: {
                                showAllAchievements = true
                            }) {
                                Text("view_all_achievements".localized())
                                    .font(.captionCustom)
                                    .foregroundColor(.accent)
                                    .padding(.top, 8)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.bottom, 100)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("profile_title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsScreen(cardsManager: cardsManager)) {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundColor(.accent)
                    }
                }
            }
            .sheet(isPresented: $showingGoalEditor) {
                GoalEditorSheet(
                    currentGoal: cardsManager.dailyGoal,
                    onSave: { newGoal in
                        cardsManager.updateDailyGoal(newGoal)
                    }
                )
            }
            .sheet(isPresented: $showAllAchievements) {
                AllAchievementsSheet(achievementsManager: achievementsManager)
            }
        }
        .languageAware()
        .onReceive(NotificationCenter.default.publisher(for: .achievementUnlocked)) { _ in
            // Обновляем UI при получении нового достижения
            withAnimation {
                isAchievementsExpanded = true
            }
        }
    }
}

// MARK: - All Achievements Sheet
struct AllAchievementsSheet: View {
    @ObservedObject var achievementsManager: AchievementsManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(achievementsManager.achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
            .background(themeManager.colors.background.ignoresSafeArea())
            .navigationTitle("all_achievements".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close".localized()) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: 40))
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray.opacity(0.3))
            
            Text(achievement.title)
                .font(.bodyCustom.weight(.semibold))
                .foregroundColor(achievement.isUnlocked ? .textPrimary : .textSecondary)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.caption2)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            if achievement.isUnlocked, let date = achievement.unlockedDate {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.accent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(themeManager.colors.cardBackground)
        .cornerRadius(16)
        .opacity(achievement.isUnlocked ? 1 : 0.6)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.isUnlocked ? Color.yellow : themeManager.colors.stroke, lineWidth: achievement.isUnlocked ? 2 : 1)
        )
    }
}

// MARK: - Enhanced Streak View (без изменений)
struct EnhancedStreakView: View {
    let streak: Int
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 35))
                    .foregroundColor(streak > 0 ? .orange : .gray)
            }
            
            VStack(spacing: 4) {
                Text("\(streak)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(streak > 0 ? .orange : .textSecondary)
                
                Text("days_in_row".localized())
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Enhanced Daily Goal View (без изменений)
struct EnhancedDailyGoalView: View {
    let goal: Int
    let solved: Int
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accent.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 60)
                
                Text("\(Int(progress * 100))%")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.accent)
            }
            
            VStack(spacing: 4) {
                Text("\(solved)/\(goal)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Text("daily_goal".localized())
                    .font(.captionCustom)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stat Card (без изменений)
struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.titleCustom)
                .foregroundColor(.textPrimary)
            Text(title)
                .font(.captionCustom)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .shadowColor, radius: 5, x: 0, y: 2)
    }
}

// MARK: - Achievement Badge (обновлённый)
struct AchievementBadge: View {
    let icon: String
    let title: String
    let unlocked: Bool
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(unlocked ? .yellow : .gray.opacity(0.3))
            Text(title)
                .font(.captionCustom)
                .foregroundColor(unlocked ? .textPrimary : .textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .background(Color.cardBackground.opacity(unlocked ? 1 : 0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(unlocked ? Color.yellow : Color.clear, lineWidth: 1)
        )
        .shadow(color: .shadowColor, radius: 3, x: 0, y: 1)
    }
}

// MARK: - Goal Editor Sheet (без изменений)
struct GoalEditorSheet: View {
    let currentGoal: Int
    let onSave: (Int) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var goalValue: Double
    
    init(currentGoal: Int, onSave: @escaping (Int) -> Void) {
        self.currentGoal = currentGoal
        self.onSave = onSave
        _goalValue = State(initialValue: Double(currentGoal))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "target")
                        .font(.system(size: 60))
                        .foregroundColor(.accent)
                    
                    Text("daily_goal".localized())
                        .font(.largeTitleCustom)
                        .foregroundColor(.textPrimary)
                    
                    Text("tap_to_change_goal".localized())
                        .font(.bodyCustom)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .stroke(Color.stroke, lineWidth: 12)
                            .frame(width: 160, height: 160)
                        
                        Circle()
                            .trim(from: 0, to: goalValue / 100)
                            .stroke(Color.accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 160, height: 160)
                        
                        Text("\(Int(goalValue))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                    
                    VStack(spacing: 8) {
                        Slider(value: $goalValue, in: 1...100, step: 1)
                            .tint(.accent)
                        
                        HStack {
                            Text("1")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text("50")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text("100")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button(action: {
                    onSave(Int(goalValue))
                    dismiss()
                }) {
                    Text("save".localized())
                        .font(.bodyCustom.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accent)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized()) {
                        dismiss()
                    }
                }
            }
        }
    }
}
