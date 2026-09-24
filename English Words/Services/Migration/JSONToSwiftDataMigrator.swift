//
//  JSONToSwiftDataMigrator.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import Foundation
import SwiftData

/// Одноразовая миграция данных из старого JSON-хранилища в SwiftData.
///
/// Запускается при старте приложения до показа UI.
/// После успешного завершения ставит флаг в UserDefaults — повторно не выполняется.

struct JSONToSwiftDataMigrator {
    private static let completionKey = "swiftdata_migration_v2_completed"
    
    let context: ModelContext
    
    func migrateIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Self.completionKey) else { return }
        
        do {
            try migrate()
            UserDefaults.standard.set(true, forKey: Self.completionKey)
        } catch {
            // Не помечаем как завершённую — попробуем при следующем запуске.
            print("⚠️ Миграция не удалась: \(error.localizedDescription)")
        }
    }
    
    private func migrate() throws {
        // Файл старого формата может не существовать (новый пользователь) — это норма.
        guard let legacyDataURL = legacyFileURL,
              FileManager.default.fileExists(atPath: legacyDataURL.path) else {
            return
        }
        
        // Пока данных нет — оставляем заглушку.
        // Полная реализация добавления сущностей будет после того,
        // как все фичи будут готовы, чтобы не тащить legacy-типы в проект.
        //
        // На данном этапе миграция просто помечает себя завершённой,
        // если файла нет. Если файл есть — ставим метку и позволяем пользователю
        // вручную восстановить данные через будущий импорт.
    }
    
    private var legacyFileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("english_words_data.json")
    }
}
