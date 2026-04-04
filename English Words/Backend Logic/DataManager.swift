//
//  DataManager.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let fileName = "english_words_data.json"
    private let userDefaults = UserDefaults.standard
    
    private var saveURL: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    // MARK: - Save Data
    func saveData(groups: [CardsGroup]) {
        guard let url = saveURL else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(groups)
            try data.write(to: url)
            print("✅ Данные сохранены: \(groups.count) групп")
        } catch {
            print("❌ Ошибка сохранения данных: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load Data
    func loadData() -> [CardsGroup]? {
        guard let url = saveURL else { return nil }
        
        // Если файла нет, возвращаем nil (будут использованы данные по умолчанию)
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("ℹ️ Файл данных не найден, будут использованы данные по умолчанию")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let groups = try decoder.decode([CardsGroup].self, from: data)
            print("✅ Данные загружены: \(groups.count) групп")
            return groups
        } catch {
            print("❌ Ошибка загрузки данных: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Clear Data
    func clearAllData() {
        guard let url = saveURL else { return }
        
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                print("🗑️ Все данные удалены из файла")
            }
        } catch {
            print("❌ Ошибка удаления данных: \(error.localizedDescription)")
        }
        
        // Очищаем UserDefaults для статистики
        let defaults = UserDefaults.standard
        let keys = ["dailyGoal", "todaySolved", "lastActiveDate", "streak", "totalSolved", "activityHistory"]
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }
    
    // MARK: - Save Statistics (UserDefaults)
    func saveStatistics(dailyGoal: Int, streak: Int, totalSolved: Int, activityHistory: [String: Bool]) {
        userDefaults.set(dailyGoal, forKey: "dailyGoal")
        userDefaults.set(streak, forKey: "streak")
        userDefaults.set(totalSolved, forKey: "totalSolved")
        
        if let data = try? JSONEncoder().encode(activityHistory) {
            userDefaults.set(data, forKey: "activityHistory")
        }
    }
    
    func loadStatistics() -> (dailyGoal: Int, streak: Int, totalSolved: Int, activityHistory: [String: Bool]) {
        let dailyGoal = userDefaults.integer(forKey: "dailyGoal")
        let streak = userDefaults.integer(forKey: "streak")
        let totalSolved = userDefaults.integer(forKey: "totalSolved")
        
        var activityHistory: [String: Bool] = [:]
        if let data = userDefaults.data(forKey: "activityHistory"),
           let history = try? JSONDecoder().decode([String: Bool].self, from: data) {
            activityHistory = history
        }
        
        return (dailyGoal == 0 ? 20 : dailyGoal, streak, totalSolved, activityHistory)
    }

    // MARK: - Storage Size
    func getStorageSize() -> String {
        guard let url = saveURL else { return "0 KB" }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            // Также нужно учесть UserDefaults (но они обычно маленькие)
            // Получаем размер всех UserDefaults (приблизительно)
            let userDefaultsSize = estimateUserDefaultsSize()
            
            let totalSize = fileSize + userDefaultsSize
            return formatBytes(totalSize)
        } catch {
            print("❌ Ошибка получения размера файла: \(error.localizedDescription)")
            return "Ошибка"
        }
    }

    private func estimateUserDefaultsSize() -> Int64 {
        // UserDefaults хранит небольшой объём данных (настройки, статистика)
        // Оцениваем приблизительно в 5-10 KB
        // Можно точнее, но для наших целей достаточно
        let defaults = UserDefaults.standard
        var totalSize: Int64 = 0
        
        // Получаем все ключи, которые использует приложение
        let appKeys = ["dailyGoal", "todaySolved", "lastActiveDate", "streak", "totalSolved", "activityHistory", "selectedTheme"]
        
        for key in appKeys {
            if let value = defaults.object(forKey: key) {
                // Приблизительная оценка размера
                if let string = value as? String {
                    totalSize += Int64(string.utf8.count)
                } else if let data = value as? Data {
                    totalSize += Int64(data.count)
                } else if let number = value as? NSNumber {
                    totalSize += 8 // приблизительно 8 байт для числа
                } else if let bool = value as? Bool {
                    totalSize += 1
                }
            }
        }
        
        return totalSize
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.includesUnit = true
        return formatter.string(fromByteCount: bytes)
    }
}
