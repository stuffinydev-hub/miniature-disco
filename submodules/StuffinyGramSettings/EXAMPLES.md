# StuffinyGram - Примеры Использования

## 🚀 Быстрый старт

### 1. Инициализация при запуске приложения

```swift
import StuffinyGramSettings

func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Инициализировать StuffinyGram
    StuffinyGramIntegration.initialize()
    
    return true
}
```

### 2. Добавить экран настроек в меню

```swift
// В SettingsViewController.swift
import StuffinyGramSettings

class SettingsViewController: UIViewController {
    func setupMenu() {
        let items = [
            // ... другие пункты меню
            ("StuffinyGram", #selector(openStuffinyGramSettings))
        ]
    }
    
    @objc func openStuffinyGramSettings() {
        let controller = stuffinyGramSettingsController(context: accountContext)
        navigationController?.pushViewController(controller, animated: true)
    }
}
```

## 📝 Примеры Логирования

### Логирование удаленного сообщения

```swift
let settings = StuffinyGramSettings.shared

// Когда пользователь удаляет сообщение в UI
func deleteMessage(_ message: Message, peerId: PeerId) {
    // Сначала логируем
    if !message.text.isEmpty {
        settings.messageLogging.logDeletedMessage(
            peerId: peerId,
            messageId: message.id,
            text: message.text
        )
    }
    
    // Потом удаляем
    deleteTelegramMessage(message)
}
```

### Получение всех логов

```swift
// Получить все удалённые сообщения
let deletedLogs = await settings.messageLogging.getDeletedMessagesLogs()
print("Всего удалённых сообщений: \(deletedLogs.count)")

for log in deletedLogs {
    print("Удалено: \(log.text)")
    print("Дата: \(Date(timeIntervalSince1970: TimeInterval(log.deletedAt)))")
}
```

## 👻 Примеры Режима Призрака

### Включить полный режим призрака

```swift
let ghostMode = settings.ghostMode

// Включить режим
ghostMode.setEnabled(true)

// Включить все функции скрытия сразу
ghostMode.enableAllFeatures()

// Или включить выборочно
ghostMode.setHideOnlineStatus(true)
ghostMode.setDisableReadReceipts(true)
ghostMode.setHideTypingStatus(true)
```

### Проверить активен ли режим

```swift
if ghostMode.isGhostModeActive() {
    print("👻 Режим призрака активен!")
}
```

### Наблюдать за изменениями

```swift
// Подписаться на изменения онлайн-статуса
let disposable = ghostMode.hideOnlineStatus.start(next: { isHidden in
    if isHidden {
        print("Ваш онлайн-статус теперь скрыт")
    }
})

// Не забыть отписаться когда не нужно
disposable?.dispose()
```

## 🛡️ Примеры Защиты Контента

### Сохранить защищённый контент

```swift
let protection = settings.contentProtection

// Включить сохранение защищённого контента
protection.setAllowSaveProtected(true)

// Когда получаем защищённое медиа
func onProtectedMediaReceived(_ media: Media, peerId: PeerId, messageId: MessageId) {
    let _ = protection.saveProtectedContent(
        media: media,
        peerId: peerId,
        messageId: messageId
    ).start(next: { success in
        if success {
            print("✓ Защищённый контент сохранён")
        }
    })
}
```

### Получить сохранённый контент

```swift
// Получить все сохранённое защищённое медиа
let _ = protection.getProtectedContent().start(next: { contents in
    print("Всего сохранено: \(contents.count)")
    
    for content in contents {
        print("Тип: \(content.mediaType)")
        print("Дата: \(Date(timeIntervalSince1970: TimeInterval(content.savedAt)))")
    }
})
```

### Отключить уведомления о скриншоте

```swift
protection.setDisableScreenshotNotification(true)

// Когда обнаружен скриншот
ScreenshotDetector.onScreenshotDetected()
// Это не отправит уведомление контакту
```

## ⭐ Примеры Локального Premium

### Активировать локальный Premium

```swift
let premium = settings.localPremium

// Включить Premium
premium.setPremiumEnabled(true)

// Или включить все премиум-функции сразу
premium.enableAllPremiumFeatures()
```

### Использовать расширенные лимиты

```swift
// Получить максимальный лимит папок
let maxFolders = premium.getMaxChatFolders()
print("Максимум папок: \(maxFolders)")  // unlimited

// Получить максимальный размер файла
let maxFileSize = premium.getMaxFileUploadSize()
print("Максимум размер файла: \(maxFileSize / 1_000_000_000)GB")  // 4GB
```

### Показать Premium бейдж

```swift
premium.setShowPremiumBadge(true)

// В UI проверить нужно ли показывать бейдж
if premium.showPremiumBadge.signal.get() ?? false {
    // Показать ⭐ бейдж рядом с именем
    showPremiumBadge()
}
```

## 📤 Примеры Экспорта/Импорта

### Экспортировать все настройки

```swift
let exported = settings.exportSettings()

// Преобразовать в JSON
if let jsonData = try? JSONSerialization.data(
    withJSONObject: exported,
    options: .prettyPrinted
),
let jsonString = String(data: jsonData, encoding: .utf8) {
    print(jsonString)
    
    // Сохранить в файл
    saveToFile(jsonString, filename: "stuffinyGram_settings.json")
}
```

### Импортировать настройки

```swift
// Загрузить JSON из файла
let jsonString = loadFromFile("stuffinyGram_settings.json")
if let jsonData = jsonString.data(using: .utf8),
   let imported = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
    
    settings.importSettings(imported)
    print("✓ Настройки импортированы")
}
```

### Сброс на значения по умолчанию

```swift
settings.resetAllToDefaults()
print("✓ Все настройки сброшены")
```

## 🔄 Реактивное Программирование

### Комбинировать несколько сигналов

```swift
// Наблюдать за несколькими изменениями сразу
combineLatest(
    ghostMode.isEnabled,
    ghostMode.hideOnlineStatus,
    ghostMode.disableReadReceipts
).start(next: { isEnabled, hideOnline, disableRead in
    print("""
    Режим: \(isEnabled ? "Включен" : "Отключен")
    Скрыт статус: \(hideOnline)
    Отключено чтение: \(disableRead)
    """)
})
```

### Использовать ValuePromise для собственного состояния

```swift
// Создать свой сигнал
let myState = ValuePromise<Bool>(false)

// Обновить значение
myState.set(true)

// Наблюдать за изменениями
myState.get().start(next: { value in
    print("Состояние: \(value)")
})
```

## ⚙️ Продвинутое Использование

### Интеграция с системой сообщений

```swift
// В TelegramCore/MessageInteraction.swift

import StuffinyGramSettings

class MessageInteractionHandler {
    func handleMessageDeletion(_ message: Message) {
        // Логирование через StuffinyGram
        MessageDeletionInterceptor.onMessageDeleted(message, peerId: peerId)
        
        // Стандартное удаление
        deleteMessage(message)
    }
}
```

### Интеграция с системой статуса

```swift
// В TelegramCore/UserStatus.swift

import StuffinyGramSettings

class StatusReporter {
    func reportTypingStatus() {
        // Проверить режим призрака
        guard TypingActivityInterceptor.shouldReportTyping(peerId) else {
            return
        }
        
        // Отправить статус печати
        sendTypingUpdate()
    }
}
```

## 💡 Советы и Лучшие Практики

1. **Инициализация** — всегда вызывайте `StuffinyGramSettings.shared.initialize()` при запуске
2. **Memory Leaks** — помните `dispose()` для всех подписок на сигналы
3. **Thread Safety** — все методы потокобезопасны, можно использовать с любого потока
4. **Логирование** — логи хранятся локально, никогда не отправляются на серверы
5. **Резервные копии** — регулярно экспортируйте настройки для резервного копирования

## 🐛 Отладка

### Проверить состояние

```swift
// Вывести все текущие настройки
let settings = StuffinyGramSettings.shared
print("Ghost Mode: \(settings.ghostMode.isEnabled.signal.get())")
print("Message Logging: \(settings.messageLogging.isEnabled.signal.get())")
print("Premium: \(settings.localPremium.isPremiumEnabled.signal.get())")
```

### Просмотреть логи

```swift
// Вывести последние удалённые сообщения
let _ = settings.messageLogging.getDeletedMessagesLogs().start(next: { logs in
    for log in logs.prefix(5) {
        print("- \(log.text)")
    }
})
```

---

📚 Полная документация доступна в прилагаемом файле `README.md`
