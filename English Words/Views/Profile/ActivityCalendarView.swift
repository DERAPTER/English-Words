//
//  ActivityCalendarView.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct ActivityCalendarView: View {
    @ObservedObject var cardsManager: CardsManager
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date?
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["calendar_mon".localized(), "calendar_tue".localized(), "calendar_wed".localized(), "calendar_thu".localized(), "calendar_fri".localized(), "calendar_sat".localized(), "calendar_sun".localized()]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок с переключением месяцев
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.accent)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.titleCustom)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.accent)
                }
            }
            .padding(.horizontal)
            
            // Дни недели
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.captionCustom)
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Сетка дней
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<days.count, id: \.self) { index in
                    if let date = days[index] {
                        DayCell(
                            date: date,
                            isActive: cardsManager.isDateActive(date),
                            isToday: calendar.isDateInToday(date),
                            onTap: { selectedDate = date }
                        )
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding(.horizontal)
            
            // Легенда
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.accent)
                        .frame(width: 12, height: 12)
                    Text("active_day".localized())
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.stroke.opacity(0.3))
                        .frame(width: 12, height: 12)
                    Text("inactive_day".localized())
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.accent.opacity(0.3))
                        .stroke(Color.accent, lineWidth: 1)
                        .frame(width: 12, height: 12)
                    Text("today".localized())
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal)
        }
        .languageAware()
        .padding(.vertical)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: .shadowColor, radius: 5, x: 0, y: 2)
        .sheet(item: $selectedDate) { date in
            DayDetailSheet(date: date, isActive: cardsManager.isDateActive(date))
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.languageCode == "ru" ? "ru_RU" : "en_US")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth).capitalized
    }
    
    private func previousMonth() {
        withAnimation {
            if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                currentMonth = newDate
            }
        }
    }
    
    private func nextMonth() {
        withAnimation {
            if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                currentMonth = newDate
            }
        }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        guard let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }
        let numberOfDays = range.count
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        let offset: Int
        if firstWeekday == 1 {
            offset = 6
        } else {
            offset = firstWeekday - 2
        }
        
        var days: [Date?] = []
        
        for _ in 0..<offset {
            days.append(nil)
        }
        
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isActive: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(isToday ? Color.accent : Color.clear, lineWidth: 2)
                    )
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.bodyCustom)
                    .foregroundColor(textColor)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        if isActive {
            return Color.accent
        } else if isToday {
            return Color.accent.opacity(0.2)
        } else {
            return Color.stroke.opacity(0.3)
        }
    }
    
    private var textColor: Color {
        if isActive {
            return .white
        } else {
            return .textSecondary
        }
    }
}

// MARK: - Day Detail Sheet
struct DayDetailSheet: View {
    let date: Date
    let isActive: Bool
    @Environment(\.dismiss) var dismiss
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 80))
                    .foregroundColor(isActive ? .accent : .gray)
                
                Text(formattedDate)
                    .font(.largeTitleCustom)
                    .foregroundColor(.textPrimary)
                
                Text(isActive ? "you_studied_on_this_day".localized() : "no_study_on_this_day".localized())
                    .font(.bodyCustom)
                    .foregroundColor(isActive ? .accent : .textSecondary)
                    .multilineTextAlignment(.center)
                
                if isActive {
                    Text("keep_it_up".localized())
                        .font(.captionCustom)
                        .foregroundColor(.textSecondary)
                } else {
                    Text("start_learning_today".localized())
                        .font(.captionCustom)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
            .padding()
            .background(Color.appBackground.ignoresSafeArea())
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
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.languageCode == "ru" ? "ru_RU" : "en_US")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date).capitalized
    }
}

// MARK: - Date Extension для sheet
extension Date: Identifiable {
    public var id: TimeInterval {
        self.timeIntervalSince1970
    }
}
