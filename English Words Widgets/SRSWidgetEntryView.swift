//
//  SRSWidgetEntryView.swift
//  English Words Widgets
//
//  Created by Егор Халиков on 09.10.2026.
//

import WidgetKit
import SwiftUI

struct SRSWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SRSWidgetEntry
    
    private var hasDue: Bool { entry.snapshot.dueToday > 0 }
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallView
            default:
                mediumView
            }
        }
        .widgetURL(URL(string: "englishwords://srs"))
    }
    
    // MARK: - Small
    
    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: hasDue ? "clock.arrow.circlepath" : "flame.fill")
                .font(.title2)
                .foregroundColor(hasDue ? .accentColor : .orange)
            
            Spacer(minLength: 0)
            
            if hasDue {
                Text("\(entry.snapshot.dueToday)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                Text("cards due")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("\(entry.snapshot.srsStreak)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.orange)
                Text("day streak")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    // MARK: - Medium
    
    private var mediumView: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(hasDue ? Color.accentColor.opacity(0.15) : Color.orange.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: hasDue ? "clock.arrow.circlepath" : "flame.fill")
                    .font(.title2)
                    .foregroundColor(hasDue ? .accentColor : .orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(hasDue ? "Time to review" : "Review streak")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(hasDue ? "\(entry.snapshot.dueToday)" : "\(entry.snapshot.srsStreak)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(hasDue ? .accentColor : .orange)
        }
    }
    
    private var subtitle: String {
        if hasDue {
            return entry.snapshot.dueToday == 1
                ? "1 card waiting"
                : "\(entry.snapshot.dueToday) cards waiting"
        }
        if entry.snapshot.srsStreak == 0 {
            return "Clear SRS to start"
        }
        return "days in a row"
    }
}

// MARK: - Previews

#Preview("Small — due", as: .systemSmall) {
    SRSWidget()
} timeline: {
    SRSWidgetEntry(date: .now, snapshot: SRSWidgetSnapshot(
        dueToday: 12, srsStreak: 5,
        nextReviewDate: nil, nextReviewCount: 0,
        updatedAt: .now
    ))
    SRSWidgetEntry(date: .now, snapshot: SRSWidgetSnapshot(
        dueToday: 0, srsStreak: 7,
        nextReviewDate: nil, nextReviewCount: 0,
        updatedAt: .now
    ))
}

#Preview("Medium — caught up", as: .systemMedium) {
    SRSWidget()
} timeline: {
    SRSWidgetEntry(date: .now, snapshot: SRSWidgetSnapshot(
        dueToday: 0, srsStreak: 7,
        nextReviewDate: nil, nextReviewCount: 0,
        updatedAt: .now
    ))
}

