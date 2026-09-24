//
//  English_WordsApp.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI
import SwiftData

@main
struct English_WordsApp: App {
    
    private let modelContainer: ModelContainer
    private let appContainer: AppContainer
    
    init() {
        // 1. Собираем ModelContainer
        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: Card.self,
                CardGroup.self,
                DailyStat.self,
                UserSettings.self
            )
        } catch {
            fatalError("Не удалось создать ModelContainer: \(error)")
        }
        self.modelContainer = container
        
        // 2. Миграция из старого JSON (если нужно)
        let migrator = JSONToSwiftDataMigrator(context: container.mainContext)
        migrator.migrateIfNeeded()
        
        // 3. Собираем DI-контейнер
        self.appContainer = AppContainer.live(container: container)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appContainer)
                .modelContainer(modelContainer)
        }
    }
}
