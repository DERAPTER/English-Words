//
//  SRSWidgetEntryView.swift
//  English Words Widgets
//
//  Created by Егор Халиков on 20.10.2026.
//

import WidgetKit
import SwiftUI

struct SRSWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: SRSWidgetEntry

    private var hasDue: Bool {
        entry.snapshot.dueToday > 0
    }

    // MARK: - Colors

    private var accent: Color {
        hasDue ? .blue : .orange
    }

    private var iconName: String {
        hasDue ? "arrow.clockwise" : "flame.fill"
    }

    private var number: Int {
        hasDue ? entry.snapshot.dueToday : entry.snapshot.srsStreak
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallView
            default:
                mediumView
            }
        }
        // Задаем стандартный отступ Apple (16pt), так как мы отключили системный
        .padding(16)
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "englishwords://srs"))
    }

    // MARK: - Small Widget
    
    private var smallView: some View {
        VStack(spacing: 0) {
            // Верхний ряд: значок слева, число справа
            HStack(alignment: .center) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.12))
                        .frame(width: 46, height: 46)

                    Image(systemName: iconName)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(accent)
                }

                Spacer(minLength: 4)

                Text("\(number)")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundStyle(accent)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .widgetAccentable()
            }

            Spacer(minLength: 8) // Добавили чуть больше воздуха

            // Нижний ряд: подписи слева, индикатор справа
            HStack(alignment: .bottom, spacing: 2) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(hasDue ? "widget_cards_due" : "widget_day_streak")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(hasDue ? "widget_lets_review" : "widget_keep_it_up")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer(minLength: 0)

                Image(systemName: hasDue ? "arrow.up.right" : "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 28, height: 28)
                    .background(accent.opacity(0.10), in: Circle())
            }
        }
    }

    // MARK: - Medium Widget

    private var mediumView: some View {
        HStack(spacing: 16) {
            // Иконка
            ZStack {
                Circle()
                    .fill(accent.opacity(0.12))

                Image(systemName: iconName)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(accent)
            }
            .frame(width: 60, height: 60)

            // Текстовый блок
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 6) {
                    Text(hasDue ? "widget_time_to_review" : "widget_review_streak")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                HStack(spacing: 4) {
                    Image(systemName: hasDue ? "sparkles" : "checkmark.circle.fill")
                    Text(hasDue ? "widget_ready_when_you_are" : "widget_all_caught_up")
                }
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
            .frame(maxHeight: .infinity)

            Spacer(minLength: 0)

            // Число
            Text("\(number)")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(accent)
                .contentTransition(.numericText())
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .widgetAccentable()
        }
    }

    // MARK: - Subtitle

    private var subtitle: String {
        if hasDue {
            return entry.snapshot.dueToday == 1
                ? String(localized: "widget_card_waiting")
                : String(format: String(localized: "widget_cards_waiting"), entry.snapshot.dueToday)
        }

        if entry.snapshot.srsStreak == 0 {
            return String(localized: "widget_start_streak")
        }

        return entry.snapshot.srsStreak == 1
            ? String(localized: "widget_1_day_learning")
            : String(format: String(localized: "widget_days_learning"), entry.snapshot.srsStreak)
    }
}

// MARK: - Previews

#Preview("Small — due", as: .systemSmall) {
    SRSWidget()
} timeline: {
    SRSWidgetEntry(date: .now, snapshot: SRSWidgetSnapshot(
        dueToday: 12,
        srsStreak: 5,
        nextReviewDate: nil,
        nextReviewCount: 0,
        updatedAt: .now
    ))
}

#Preview("Small — streak", as: .systemSmall) {
    SRSWidget()
} timeline: {
    SRSWidgetEntry(date: .now, snapshot: SRSWidgetSnapshot(
        dueToday: 0,
        srsStreak: 7,
        nextReviewDate: nil,
        nextReviewCount: 0,
        updatedAt: .now
    ))
}

#Preview("Medium — due", as: .systemMedium) {
    SRSWidget()
} timeline: {
    SRSWidgetEntry(date: .now, snapshot: SRSWidgetSnapshot(
        dueToday: 12,
        srsStreak: 5,
        nextReviewDate: nil,
        nextReviewCount: 0,
        updatedAt: .now
    ))
}

#Preview("Medium — caught up", as: .systemMedium) {
    SRSWidget()
} timeline: {
    SRSWidgetEntry(date: .now, snapshot: SRSWidgetSnapshot(
        dueToday: 0,
        srsStreak: 7,
        nextReviewDate: nil,
        nextReviewCount: 0,
        updatedAt: .now
    ))
}
