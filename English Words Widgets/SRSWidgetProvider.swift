//
//  SRSWidgetProvider.swift
//  English Words Widgets
//
//  Created by Егор Халиков on 09.10.2026.
//

import WidgetKit
import SwiftUI

struct SRSWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: SRSWidgetSnapshot
}

struct SRSWidgetProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> SRSWidgetEntry {
        SRSWidgetEntry(date: .now, snapshot: .empty)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SRSWidgetEntry) -> Void) {
        let snapshot = SRSWidgetStore.load()
        completion(SRSWidgetEntry(date: .now, snapshot: snapshot))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SRSWidgetEntry>) -> Void) {
        let snapshot = SRSWidgetStore.load()
        let entry = SRSWidgetEntry(date: .now, snapshot: snapshot)
        
        // Обновляем раз в час. Основные обновления приходят
        // через WidgetCenter.reloadAllTimelines() из приложения.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        let timeline = Timeline(entries: [entry], policy: .after(next))
        completion(timeline)
    }
}
