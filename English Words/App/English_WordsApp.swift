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
                        .onOpenURL { url in
                            handleDeepLink(url)
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                NotificationService.shared.requestPermission()
                            }
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                updateReminderOnBackground()
            }
        }
    }
    
    // MARK: - Инициализация
    
    @MainActor
    private func initializeApp() async {
        try? await Task.sleep(for: .milliseconds(1200))
        
        do {
            let container = try ModelContainer(
                for: Card.self, CardGroup.self, DailyStat.self, UserSettings.self
            )
            
            let migrator = JSONToSwiftDataMigrator(context: container.mainContext)
            migrator.migrateIfNeeded()
            
            let app = AppContainer.live(container: container)
            
            withAnimation(.easeInOut(duration: 0.5)) {
                self.modelContainer = container
                self.appContainer = app
            }
            
            updateReminderOnBackground()
            
        } catch {
            fatalError("Не удалось создать ModelContainer: \(error)")
        }
    }
    
    // MARK: - Notifications Logic
    
    @MainActor
    private func updateReminderOnBackground() {
        guard let appContainer else { return }
        
        let limit = UserDefaults.standard.integer(forKey: "srsNewCardsPerDay")
        let effectiveLimit = limit > 0 ? limit : 20
        
        if let overview = try? appContainer.cardRepository.srsOverview(on: .now, newCardsLimit: effectiveLimit) {
            NotificationService.shared.scheduleSRSReminder(hasDueCards: overview.dueToday > 0)
        }
    }
    
    // MARK: - Deep link
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "englishwords" else { return }
        NotificationCenter.default.post(name: .openSRSTab, object: nil)
    }
}

extension Notification.Name {
    static let openSRSTab = Notification.Name("openSRSTab")
}
