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
    
    @Environment(\.scenePhase) private var scenePhase
    
    private let modelContainer: ModelContainer
    private let appContainer: AppContainer
    
    init() {
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
        
        let migrator = JSONToSwiftDataMigrator(context: container.mainContext)
        migrator.migrateIfNeeded()
        
        self.appContainer = AppContainer.live(container: container)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appContainer)
                .modelContainer(modelContainer)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                refreshWidgetSnapshot()
            }
        }
    }
    
    // MARK: - Deep link
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "englishwords" else { return }
        // В будущем можно открывать конкретный таб.
        // Пока просто открываем приложение — SRS доступен через таб.
        // Если захочешь навигировать на SRS-таб — это делается через
        // отдельный AppStorage-флаг или NotificationCenter.
        NotificationCenter.default.post(
            name: .openSRSTab,
            object: nil
        )
    }
    
    // MARK: - Widget snapshot
    
    private func refreshWidgetSnapshot() {
        SRSWidgetSnapshotWriter.refresh(
            cardRepository: appContainer.cardRepository,
            statsRepository: appContainer.statsRepository
        )
    }
}

extension Notification.Name {
    static let openSRSTab = Notification.Name("openSRSTab")
}
