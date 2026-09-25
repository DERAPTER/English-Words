//
//  SolveGroupKey.swift
//  English Words
//
//  Created by Егор Халиков on 25.09.2026.
//

import Foundation

/// Идентификатор группы для сессии нарешивания.
/// Системные группы отличаются от пользовательских префиксом.
enum SolveGroupKey: Hashable, Codable {
    case system(SystemGroupType)
    case user(UUID)
    
    var stringValue: String {
        switch self {
        case .system(let type): return "system_\(type.rawValue)"
        case .user(let id):     return "user_\(id.uuidString)"
        }
    }
    
    init?(stringValue: String) {
        if stringValue.hasPrefix("system_") {
            let raw = String(stringValue.dropFirst("system_".count))
            guard let type = SystemGroupType(rawValue: raw) else { return nil }
            self = .system(type)
        } else if stringValue.hasPrefix("user_") {
            let raw = String(stringValue.dropFirst("user_".count))
            guard let uuid = UUID(uuidString: raw) else { return nil }
            self = .user(uuid)
        } else {
            return nil
        }
    }
}
