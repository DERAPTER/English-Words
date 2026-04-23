# 🏗 Техническая документация English Words

## 📦 Общая архитектура

Приложение построено по паттерну MV (Model-View) с менеджерами состояния. Все данные хранятся локально без использования сторонних библиотек.

    English Words/
    ├── Backend Logic/           # Менеджеры и модели данных
    │   ├── CardsManager         # Управление карточками и группами
    │   ├── AchievementsManager  # Система достижений
    │   ├── ThemeManager         # Цветовые темы
    │   ├── LanguageManager      # Локализация
    │   └── DataManager          # Сохранение/загрузка JSON
    │
    ├── Views/                   # SwiftUI интерфейс
    │   ├── CardsGroups/         # Управление группами и карточками
    │   ├── SolveCard/           # Режим изучения
    │   ├── Profile/             # Профиль и статистика
    │   ├── Settings/            # Настройки
    │   └── TabBar/              # Навигация
    │
    └── Models/                  # Модели данных
        ├── Card                 # Модель карточки
        ├── Cards                # Контейнер с логикой изучения
        ├── CardsGroup           # Группа карточек
        └── Achievement          # Модель достижения


## 🔄 Поток данных

    User Action → View → Manager → DataManager → FileManager/UserDefaults
                    ↓
               View Update ← @Published ← ObservableObject


### Пример: Добавление карточки

1. Пользователь вводит слово и перевод в AddNewCardScreen
2. View вызывает cardsManager.addCardToGroup(card:groupName:)
3. CardsManager добавляет карточку в группу и в "All Cards"
4. Вызывается DataManager.saveData(groups:)
5. Данные сохраняются в JSON файл в Documents Directory
6. @Published var groups обновляется
7. SwiftUI автоматически перерисовывает все связанные View


## 🧩 Ключевые технические решения

### 1. Сериализация ObservableObject в JSON

Проблема: Классы с @Published свойствами не поддерживают Codable из коробки.

Решение: Ручная реализация CodingKeys и методов encode/decode.

    class Card: ObservableObject, Equatable, Codable {
        let id: UUID
        @Published var originWord: String
        @Published var translatedWord: String
        @Published var groups: [String]
        let dateAdded: Date
        @Published var correctCount: Int
        @Published var wrongCount: Int
    
        enum CodingKeys: String, CodingKey {
            case id, originWord, translatedWord, groups, dateAdded, correctCount, wrongCount
        }
    
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            originWord = try container.decode(String.self, forKey: .originWord)
            translatedWord = try container.decode(String.self, forKey: .translatedWord)
            groups = try container.decode([String].self, forKey: .groups)
            dateAdded = try container.decode(Date.self, forKey: .dateAdded)
            correctCount = try container.decode(Int.self, forKey: .correctCount)
            wrongCount = try container.decode(Int.self, forKey: .wrongCount)
        }
    
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(originWord, forKey: .originWord)
            try container.encode(translatedWord, forKey: .translatedWord)
            try container.encode(groups, forKey: .groups)
            try container.encode(dateAdded, forKey: .dateAdded)
            try container.encode(correctCount, forKey: .correctCount)
            try container.encode(wrongCount, forKey: .wrongCount)
        }
    }


### 2. Сохранение состояния сессии изучения

Проблема: При незавершённой сессии нужно запомнить, какие карточки уже решены, а какие ещё нет.

Решение: Сохраняются только ID карточек для каждого состояния. При загрузке объекты восстанавливаются по ID из общего массива.

    class Cards: ObservableObject, Codable {
        @Published var cardsArr: [Card] = []
        @Published var success: [Card] = []
        @Published var fail: [Card] = []
        @Published var unsolved: [Card] = []
    
        enum CodingKeys: String, CodingKey {
            case cardsArr, successIds, failIds, unsolvedIds
        }
    
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(cardsArr, forKey: .cardsArr)
            try container.encode(success.map { $0.id }, forKey: .successIds)
            try container.encode(fail.map { $0.id }, forKey: .failIds)
            try container.encode(unsolved.map { $0.id }, forKey: .unsolvedIds)
        }
    
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            cardsArr = try container.decode([Card].self, forKey: .cardsArr)
        
            let successIds = try container.decode([UUID].self, forKey: .successIds)
            let failIds = try container.decode([UUID].self, forKey: .failIds)
            let unsolvedIds = try container.decode([UUID].self, forKey: .unsolvedIds)
        
            success = cardsArr.filter { successIds.contains($0.id) }
            fail = cardsArr.filter { failIds.contains($0.id) }
            unsolved = cardsArr.filter { unsolvedIds.contains($0.id) }
        }
    }


### 3. Динамическая система тем

Проблема: Мгновенное переключение цветовой темы без перезагрузки приложения.

Решение: Комбинация @Published, NotificationCenter и модификатора .id(refreshTrigger).

    class ThemeManager: ObservableObject {
        static let shared = ThemeManager()
    
        @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.beige.rawValue
    
        @Published var currentTheme: AppTheme {
            didSet {
                selectedThemeRaw = currentTheme.rawValue
                applyNavigationBarAppearance()
                NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
            }
        }
    }

    struct ThemeAwareViewModifier: ViewModifier {
        @ObservedObject private var themeManager = ThemeManager.shared
        @State private var refreshTrigger = false
    
        func body(content: Content) -> some View {
            content
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ThemeChanged"))) { _ in
                    refreshTrigger.toggle()
                }
                .id(refreshTrigger)
                .preferredColorScheme(themeManager.currentTheme == .beige || themeManager.currentTheme == .pink ? .light : .dark)
        }
    }


### 4. Локализация на лету

Проблема: Переключение языка без перезапуска приложения.

Решение: Кастомный LanguageManager, который переопределяет Bundle и уведомляет View через NotificationCenter.

    class LanguageManager: ObservableObject {
        static let shared = LanguageManager()
    
        @AppStorage("appLanguage") private var languageRaw: String = AppLanguage.english.rawValue
    
        @Published var currentLanguage: AppLanguage {
            didSet {
                languageRaw = currentLanguage.rawValue
                setLanguage(currentLanguage)
            }
        }
    
        private var bundle: Bundle?
    
        func setLanguage(_ language: AppLanguage) {
            UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
            bundle = LanguageManager.getBundle(for: language)
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        }
    }

    extension String {
        func localized() -> String {
            return LanguageManager.shared.localizedString(self)
        }
    }


### 5. Свайп-жесты с предикцией

Проблема: Плавное завершение свайпа даже если пользователь отпустил палец рано.

Решение: Использование predictedEndTranslation в DragGesture.

    DragGesture()
        .onChanged { value in
            offsetOfCardX = value.translation.width
        }
        .onEnded { value in
            let translation = value.translation.width
            let predictedEnd = value.predictedEndTranslation.width
        
            if translation < -swipeThreshold || predictedEnd < -swipeThreshold {
                cards.solveFail(card: currentCard)
            } else if translation > swipeThreshold || predictedEnd > swipeThreshold {
                cards.solveSuccess(card: currentCard)
                cardsManager.recordSolvedCard()
            }
        }


### 6. Flip-анимация карточки

    struct CardView: View {
        @State private var isFlipped = false
    
        var body: some View {
            ZStack {
                frontView.opacity(isFlipped ? 0 : 1)
                backView.opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .onTapGesture {
                withAnimation(.spring()) {
                    isFlipped.toggle()
                }
            }
        }
    }


### 7. Система достижений

Проблема: Отслеживание прогресса по разным метрикам и разблокировка достижений.

Решение: Единый менеджер, который проверяет условия при каждом изменении данных.

    class AchievementsManager: ObservableObject {
        static let shared = AchievementsManager()
    
        @Published var achievements: [Achievement] = []
        @Published var recentlyUnlocked: Achievement? = nil
    
        func checkAchievements(cardsManager: CardsManager) {
            for i in 0..<achievements.count {
                if !achievements[i].isUnlocked {
                    let isUnlocked = checkCondition(achievements[i], cardsManager: cardsManager)
                    if isUnlocked {
                        achievements[i].isUnlocked = true
                        achievements[i].unlockedDate = Date()
                        recentlyUnlocked = achievements[i]
                    
                        NotificationCenter.default.post(name: .achievementUnlocked, object: achievements[i])
                    
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                            self?.recentlyUnlocked = nil
                        }
                    }
                }
            }
        }
    }


### 8. Кастомный FlowLayout для чипсов

    struct FlowLayout: Layout {
        var spacing: CGFloat = 8
    
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
            var width: CGFloat = 0
            var height: CGFloat = 0
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            let maxWidth = proposal.width ?? .infinity
        
            for size in sizes {
                if currentX + size.width > maxWidth, currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
                width = max(width, currentX)
            }
            height = currentY + lineHeight
            return CGSize(width: width, height: height)
        }
    
        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            var currentX = bounds.minX
            var currentY = bounds.minY
            var lineHeight: CGFloat = 0
            let maxX = bounds.maxX
        
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                if currentX + size.width > maxX, currentX > bounds.minX {
                    currentX = bounds.minX
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }
    }


## 💾 Хранение данных

| Тип данных            | Способ хранения                    | Формат       |
|-----------------------|------------------------------------|--------------|
| Карточки и группы     | FileManager (Documents Directory)  | JSON         |
| Статистика            | UserDefaults + @AppStorage         | Примитивы    |
| Активность по дням    | UserDefaults                       | JSON строка  |
| Достижения            | UserDefaults                       | JSON         |
| Настройки темы        | @AppStorage                        | String       |
| Настройки языка       | @AppStorage                        | String       |


## 🧪 Тестирование

Проект включает unit-тесты для ключевых компонентов:

| Тестовый класс         | Покрываемый компонент              |
|------------------------|------------------------------------|
| CardsManagerTests      | CRUD операции с карточками и группами |
| CardsTests             | Логика сессии изучения             |
| CardTests              | Модель карточки                    |
| DataManagerTests       | Сохранение и загрузка данных       |
| StreakTests            | Логика подсчёта серии              |
| LanguageManagerTests   | Переключение локализации           |
| ThemeManagerTests      | Переключение тем                   |

Запуск тестов:
xcodebuild test -scheme "English Words" -destination 'platform=iOS Simulator,name=iPhone 15'


## ⚡ Производительность

- Ленивая загрузка: LazyVStack, LazyVGrid для списков карточек
- Оптимизация идентификации: Identifiable на всех моделях
- Условные перерисовки: @ObservedObject только там, где данные реально меняются
- Дебаунсинг поиска: При выборе существующих карточек поиск фильтрует локальный массив без задержек


## 🔧 Требования к сборке

- Xcode: 15.0+
- iOS Deployment Target: 16.0
- Swift: 5.9
- Зависимости: Отсутствуют


## 📱 Поддерживаемые устройства

- iPhone (все модели с iOS 16.0+)
- iPad (адаптивный интерфейс)
- Mac (через Mac Catalyst, требуется доработка)
