//
//  ReleaseNotesSheet.swift
//  English Words
//
//  Created by Егор Халиков on 04.04.2026.
//

import SwiftUI

struct ReleaseNotesSheet: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    /*
                    // Текущая версия
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.accent)
                            Text("Version 1.3.0")
                                .font(.titleCustom)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("Current version")
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "paintpalette", text: "Added 4 color themes (Beige, Green, Blue, Pink)")
                            ReleaseNoteItem(icon: "globe", text: "Added language selection (English / Русский)")
                            ReleaseNoteItem(icon: "calendar", text: "Added activity calendar")
                            ReleaseNoteItem(icon: "chart.bar", text: "Added detailed statistics")
                            ReleaseNoteItem(icon: "arrow.counterclockwise", text: "Session saving between app launches")
                        }
                    }
                    
                    // Предыдущие версии (шаблон)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("Version 1.2.0")
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("Previous version")
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "Added swipe to delete cards and groups")
                            ReleaseNoteItem(icon: "star", text: "Added favorites section")
                            ReleaseNoteItem(icon: "folder", text: "Added group management")
                        }
                    }
                    
                    // Ещё более старая версия (шаблон)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("Version 1.1.0")
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("Previous version")
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "rectangle.stack", text: "Added card creation and editing")
                            ReleaseNoteItem(icon: "arrow.left.arrow.right", text: "Added swipe gestures for learning")
                            ReleaseNoteItem(icon: "checkmark.circle", text: "Added progress tracking")
                        }
                    }
                    
                    // Первая версия (шаблон)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "flag.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("Version 1.0.0")
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("Initial release")
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "iphone", text: "Initial release of English Words")
                            ReleaseNoteItem(icon: "folder", text: "Basic group and card management")
                            ReleaseNoteItem(icon: "graduationcap", text: "Card learning mode")
                        }
                    }
                    */
                    
                    // v1.0.5
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("Version 1.0.5")
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("Предыдущая версия")
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "Системная группа больше не отображается при создании новой карточки")
                            ReleaseNoteItem(icon: "plus.circle", text: "Добавлена информация о самом умном, гениальном, талантливом, а самое главное - скромном, разработчике")
                            ReleaseNoteItem(icon: "plus.circle", text: "Улучшен визуал счетчика правильных/неправильных ответов")
                        }
                    }
                    
                    // v1.0.4
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("Version 1.0.4")
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("Предыдущая версия")
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "Измененное имя группы теперь сразу применяется")
                            ReleaseNoteItem(icon: "plus.circle", text: "Исправлено дублирование карточек при добавлении через первую группу")
                            ReleaseNoteItem(icon: "plus.circle", text: "Исправлена логика счетчика серии активности")
                        }
                    }
                    
                    // v1.0.3
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("Version 1.0.3")
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("Предыдущая версия")
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "Добавлен отдельный экран для пустой группы")
                            ReleaseNoteItem(icon: "plus.circle", text: "Исправлено редактирование имени группы")
                        }
                    }
                    
                    // v1.0.2
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("Version 1.0.2")
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("Предыдущая версия")
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "Исправлена локализация при нарешивании карточек")
                            ReleaseNoteItem(icon: "plus.circle", text: "Исправлено поведение карточки при нарешивании")
                            ReleaseNoteItem(icon: "plus.circle", text: "Исправлен цвет ссылок навигации")
                            ReleaseNoteItem(icon: "plus.circle", text: "В меню настроек убрана дублированная кнопка выхода")
                        }
                    }
                    
                    // v1.0.1
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("Version 1.0.1")
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("Предыдущая версия")
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "Добавлен отчет об изменениях в новых версиях")
                            ReleaseNoteItem(icon: "plus.circle", text: "Исправлено: при полной очистке данных тестовые карточки и группы не удалялись")
                            ReleaseNoteItem(icon: "plus.circle", text: "Визуально улучшен свайп карточки для редактирования")
                            ReleaseNoteItem(icon: "plus.circle", text: "Системные группы больше нельзя удалять и редактировать, с целью безопасности")
                        }
                    }
                    
                    // Первая версия v1.0.0
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "flag.fill")
                                .foregroundColor(themeManager.colors.textSecondary)
                            Text("Version 1.0.0")
                                .font(.title3)
                                .foregroundColor(themeManager.colors.textPrimary)
                        }
                        
                        Text("Initial release")
                            .font(.captionCustom)
                            .foregroundColor(themeManager.colors.textSecondary)
                        
                        Divider()
                            .background(themeManager.colors.stroke)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность добавлять свои карточки")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность добавлять свои группы")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность редактировать и удалять карточки")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность редактировать и удалять группы")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность выбора группы для нарешивания")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность нарешивания карточек группы")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность увидеть успешность нарешивания группы")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность повторить только ошибки или перепройти группу полностью")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность установить ежедневную цель")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность отследить активные дни")
                            ReleaseNoteItem(icon: "plus.circle", text: "Добавлены достижения")
                            ReleaseNoteItem(icon: "plus.circle", text: "Сохранение данных в постоянную память")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность выбрать одну из 4 цветовых тем")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность выбрать один из языков: Русский/Английский")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность обнулить всю статистику")
                            ReleaseNoteItem(icon: "plus.circle", text: "Возможность удалить все данные")
                        }
                    }
                }
                .padding()
            }
            .background(themeManager.colors.background.ignoresSafeArea())
            .navigationTitle("release_notes".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close_button".localized()) {
                        dismiss()
                    }
                    .foregroundColor(themeManager.colors.accent)
                }
            }
        }
    }
}

// MARK: - Release Note Item
struct ReleaseNoteItem: View {
    let icon: String
    let text: String
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(themeManager.colors.accent)
                .frame(width: 20)
            
            Text(text)
                .font(.bodyCustom)
                .foregroundColor(themeManager.colors.textPrimary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ReleaseNotesSheet()
}
