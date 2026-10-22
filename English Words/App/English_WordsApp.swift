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
    
    @State private var modelContainer: ModelContainer?
    @State private var appContainer: AppContainer?
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if let container = appContainer, let model = modelContainer {
                    RootView()
                        .environment(container)
                        .modelContainer(model)
                        .transition(.opacity)
                        // Обработка открытия по ссылке (из виджета)
                        .onOpenURL { url in
                            handleDeepLink(url)
                        }
                } else {
                    SplashGreetingView()
                        .transition(.opacity)
                }
            }
            .task {
                await initializeApp()
            }
        }
    }
    
    // MARK: - Инициализация
    
    @MainActor
    private func initializeApp() async {
        // Небольшая задержка, чтобы приветствие не мелькнуло слишком быстро
        try? await Task.sleep(for: .milliseconds(1200))
        
        do {
            let container = try ModelContainer(
                for: Card.self,
                CardGroup.self,
                DailyStat.self,
                UserSettings.self
            )
            
            let migrator = JSONToSwiftDataMigrator(context: container.mainContext)
            migrator.migrateIfNeeded()
            
            let app = AppContainer.live(container: container)
            
            withAnimation(.easeInOut(duration: 0.5)) {
                self.modelContainer = container
                self.appContainer = app
            }
            
        } catch {
            fatalError("Не удалось создать ModelContainer: \(error)")
        }
    }
    
    // MARK: - Deep link
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "englishwords" else { return }
        NotificationCenter.default.post(
            name: .openSRSTab,
            object: nil
        )
    }
}

// MARK: - Notifications Extension

extension Notification.Name {
    static let openSRSTab = Notification.Name("openSRSTab")
}
