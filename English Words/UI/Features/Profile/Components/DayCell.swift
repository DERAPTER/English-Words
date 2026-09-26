//
//  DayCell.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI

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
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        if isActive { return .accent }
        if isToday { return .accent.opacity(0.2) }
        return .stroke.opacity(0.3)
    }
    
    private var textColor: Color {
        isActive ? .white : .textSecondary
    }
}
