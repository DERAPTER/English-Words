//
//  StorageSizeCalculator.swift
//  English Words
//
//  Created by Егор Халиков on 27.09.2026.
//

import Foundation

/// Считает примерный размер данных приложения.
enum StorageSizeCalculator {
    
    static func calculate() -> String {
        let fileManager = FileManager.default
        var total: Int64 = 0
        
        // 1. Размер SwiftData-хранилища
        if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            total += directorySize(at: appSupport, fileManager: fileManager)
        }
        
        // 2. Размер Documents (старый JSON — если есть)
        if let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            total += directorySize(at: documents, fileManager: fileManager)
        }
        
        return format(total)
    }
    
    // MARK: - Private
    
    private static func directorySize(at url: URL, fileManager: FileManager) -> Int64 {
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey]
        ) else { return 0 }
        
        var size: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard
                let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
                values.isRegularFile == true,
                let fileSize = values.fileSize
            else { continue }
            size += Int64(fileSize)
        }
        return size
    }
    
    private static func format(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.includesUnit = true
        return formatter.string(fromByteCount: bytes)
    }
}
