//
//  NotificationService.swift
//  English Words
//
//  Created by Егор Халиков on 24.10.2026.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()
    
    private let reminderIdentifier = "daily_srs_reminder"
    
    private init() {}
    
    // MARK: - Permission
    
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Ошибка запроса разрешения на уведомления: \(error.localizedDescription)")
            } else {
                print("✅ Разрешение на уведомления: \(granted ? "Да" : "Нет")")
            }
        }
    }
    
    // MARK: - Scheduling
    
    /// Планирует напоминание на 20:00, если есть что повторять.
    func scheduleSRSReminder(hasDueCards: Bool) {
        // Сначала удаляем старое уведомление, чтобы не дублировалось
        cancelSRSReminder()
        
        guard hasDueCards else { return }
        
        let center = UNUserNotificationCenter.current()
        
        // Проверяем, не запретил ли пользователь уведомления в настройках
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "notification_srs_title".localized()
            content.body = "notification_srs_body".localized()
            content.sound = .default
            
            // Настраиваем время: 20:00 ближайшего дня
            var dateComponents = DateComponents()
            dateComponents.hour = 20
            dateComponents.minute = 0
            
            // Триггер сработает в ближайшие 20:00 (если уже вечер, то завтра)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: self.reminderIdentifier,
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Ошибка добавления уведомления: \(error.localizedDescription)")
                } else {
                    print("✅ Напоминание SRS запланировано на 20:00")
                }
            }
        }
    }
    
    /// Отменяет запланированное напоминание (например, если пользователь всё выучил).
    func cancelSRSReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        print("🗑️ Напоминание SRS отменено")
    }
}
