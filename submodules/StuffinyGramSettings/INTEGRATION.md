# Интеграция StuffinyGram в Telegram

Данный документ описывает, как интегрировать модуль StuffinyGramSettings в основное приложение Telegram.

## 📋 Проверка Списка Интеграции

### 1. Bazel Конфигурация
- [ ] Добавить зависимость в `Telegram/BUILD`:
  ```python
  deps = [
      "//submodules/StuffinyGramSettings:StuffinyGramSettings",
  ]
  ```

### 2. Инициализация при Запуске

**Файл**: `Telegram/Telegram-iOS/Application.swift`

```swift
import StuffinyGramSettings

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, 
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Инициализировать StuffinyGram после инициализации основного приложения
        DispatchQueue.main.async {
            StuffinyGramIntegration.initialize()
        }
        
        return true
    }
}
```

### 3. Добавить в Меню Настроек

**Файл**: `Telegram/TelegramUI/SettingsViewController.swift`

```swift
import StuffinyGramSettings

class SettingsViewController: ItemListController {
    
    private func buildEntries() -> [SettingsEntry] {
        var entries: [SettingsEntry] = []
        
        // ... существующие пункты ...
        
        // Добавить пункт StuffinyGram
        entries.append(
            .custom(
                sectionId: .stuffinyGram,
                height: 44,
                item: ItemListActionItem(
                    presentationData: presentationData,
                    title: "StuffinyGram",
                    kind: .generic,
                    alignment: .natural,
                    sectionId: .stuffinyGram,
                    style: .blocks,
                    action: { [weak self] in
                        self?.openStuffinyGramSettings()
                    }
                ),
                insets: .zero
            )
        )
        
        return entries
    }
    
    private func openStuffinyGramSettings() {
        let controller = stuffinyGramSettingsController(context: self.context)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
```

### 4. Перехват Удаления Сообщений

**Файл**: `TelegramCore/ChatHistoryState.swift`

```swift
import StuffinyGramSettings

class ChatHistoryState {
    
    func removeMessages(_ messages: [Message], peerId: PeerId) {
        // Логировать удаление перед удалением
        for message in messages {
            MessageDeletionInterceptor.onMessageDeleted(message, peerId: peerId)
        }
        
        // Стандартное удаление
        // ... существующий код ...
    }
}
```

### 5. Перехват Редактирования Сообщений

**Файл**: `TelegramCore/MessageEditState.swift`

```swift
import StuffinyGramSettings

class MessageEditState {
    
    func editMessage(_ message: Message, text: String, peerId: PeerId) {
        let originalText = message.text ?? ""
        
        // Логировать редактирование перед обновлением
        MessageEditInterceptor.onMessageEdited(message, originalText: originalText, peerId: peerId)
        
        // Стандартное редактирование
        // ... существующий код ...
    }
}
```

### 6. Перехват Статуса Печати

**Файл**: `TelegramCore/PresenceManager.swift`

```swift
import StuffinyGramSettings

class PresenceManager {
    
    func reportTypingActivity(_ peerId: PeerId) {
        // Проверить режим призрака
        guard TypingActivityInterceptor.shouldReportTyping(peerId) else {
            return
        }
        
        // Отправить статус печати
        // ... существующий код ...
    }
    
    func reportOnlineStatus() {
        // Проверить скрытие онлайн-статуса
        guard OnlineStatusInterceptor.shouldReportOnlineStatus() else {
            return
        }
        
        // Отправить онлайн-статус
        // ... существующий код ...
    }
}
```

### 7. Перехват Подтверждения Прочтения

**Файл**: `TelegramCore/MessageReadState.swift`

```swift
import StuffinyGramSettings

class MessageReadState {
    
    func markMessagesAsRead(_ messages: [MessageId], peerId: PeerId) {
        // Фильтровать сообщения если режим призрака активен
        let messagesToRead = messages.filter { messageId in
            ReadReceiptInterceptor.shouldSendReadReceipt(peerId, messageId: messageId)
        }
        
        guard !messagesToRead.isEmpty else { return }
        
        // Отправить подтверждение прочтения
        // ... существующий код ...
    }
}
```

### 8. Перехват Загрузки Медиа

**Файл**: `TelegramCore/MediaUploadState.swift`

```swift
import StuffinyGramSettings

class MediaUploadState {
    
    func uploadMedia(_ media: Media, to peerId: PeerId) {
        // Проверить нужно ли показывать статус загрузки
        guard MediaUploadInterceptor.shouldReportMediaUpload(peerId) else {
            // Загрузить в фоне без индикатора печати
            performSilentUpload(media, to: peerId)
            return
        }
        
        // Стандартная загрузка с индикатором
        // ... существующий код ...
    }
}
```

### 9. Защита Контента

**Файл**: `TelegramCore/MediaReceiverState.swift`

```swift
import StuffinyGramSettings

class MediaReceiverState {
    
    func onMediaReceived(_ media: Media, messageId: MessageId, peerId: PeerId, flags: MessageFlags) {
        // Проверить нужно ли сохранить защищённый контент
        if flags.contains(.protectedContent) {
            ProtectedContentHandler.onProtectedMediaReceived(media, messageId: messageId, peerId: peerId)
        }
        
        // Проверить TTL (self-destructing)
        if let ttl = media.ttl, ttl > 0 {
            SelfDestructingContentHandler.onSelfDestructingMediaReceived(
                media, 
                messageId: messageId, 
                peerId: peerId,
                ttl: ttl
            )
        }
        
        // Стандартная обработка медиа
        // ... существующий код ...
    }
}
```

### 10. Обнаружение Скриншотов

**Файл**: `TelegramUI/ScreenshotDetector.swift` (новый файл)

```swift
import UIKit
import StuffinyGramSettings

class ScreenshotDetectionManager {
    static let shared = ScreenshotDetectionManager()
    
    private var screenshotDetection: NSObjectProtocol?
    
    func setupScreenshotDetection() {
        screenshotDetection = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            ScreenshotDetector.onScreenshotDetected()
        }
    }
    
    func tearDown() {
        if let observer = screenshotDetection {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
```

Добавить в AppDelegate:
```swift
func applicationDidFinishLaunching(_ application: UIApplication) {
    ScreenshotDetectionManager.shared.setupScreenshotDetection()
}
```

### 11. Управление Лимитами Папок

**Файл**: `TelegramCore/ChatFolderState.swift`

```swift
import StuffinyGramSettings

class ChatFolderState {
    
    var maxChatFolders: Int {
        return ChatFolderLimitManager.getMaxFolders()
    }
    
    var maxPinnedChats: Int {
        return ChatFolderLimitManager.getMaxPinnedChats()
    }
}
```

### 12. Размер Файлов для Загрузки

**Файл**: `TelegramCore/DocumentUploadState.swift`

```swift
import StuffinyGramSettings

class DocumentUploadState {
    
    var maxUploadSize: Int64 {
        return FileUploadLimitManager.getMaxUploadSize()
    }
    
    func validateFileSize(_ size: Int64) -> Bool {
        return size <= maxUploadSize
    }
}
```

### 13. Premium Бейдж в UI

**Файл**: `TelegramUI/UserProfileHeaderView.swift`

```swift
import StuffinyGramSettings

class UserProfileHeaderView: UIView {
    
    func updateProfileHeader(for user: TelegramUser) {
        // ... существующий код ...
        
        // Показать Premium бейдж если включен
        if user.isPremium || PremiumBadgeManager.shouldShowPremiumBadge() {
            addPremiumBadge()
        }
    }
}
```

## 🧪 Тестирование Интеграции

### Проверка инициализации

```swift
import StuffinyGramSettings

func testInitialization() {
    StuffinyGramIntegration.initialize()
    
    let version = StuffinyGramIntegration.getVersion()
    XCTAssertEqual(version, "1.0.0")
    
    let settings = StuffinyGramSettings.shared
    XCTAssertNotNil(settings)
}
```

### Проверка логирования

```swift
func testMessageLogging() {
    let logging = StuffinyGramSettings.shared.messageLogging
    logging.setLogDeletedMessages(true)
    
    logging.logDeletedMessage(
        peerId: PeerId(namespace: 1, id: 123),
        messageId: MessageId(peerId: PeerId(namespace: 1, id: 123), id: 456),
        text: "Test message"
    )
    
    let logs = logging.getDeletedMessagesLogs()
    XCTAssertEqual(logs.count, 1)
    XCTAssertEqual(logs.first?.text, "Test message")
}
```

## 🔄 Синхронизация между Устройствами

Используйте iCloud для синхронизации настроек (опционально):

```swift
import CloudKit

class SettingsSyncManager {
    func syncSettingsToCloud() {
        let settings = StuffinyGramSettings.shared.exportSettings()
        // Загрузить в CloudKit
    }
    
    func syncSettingsFromCloud() {
        // Загрузить из CloudKit
        let settings = // ...
        StuffinyGramSettings.shared.importSettings(settings)
    }
}
```

## ⚠️ Важные Замечания

1. **App Groups** — убедитесь, что у приложения есть entitlement для `group.stuffinyGram`
2. **Privacy** — все данные хранятся локально и никогда не отправляются на серверы Telegram
3. **Performance** — SQLite база работает асинхронно, это не должно влиять на UI
4. **Compatibility** — требуется iOS 14.0+

## 📞 Поддержка

Для вопросов интеграции обратитесь к файлам документации:
- `README.md` — общая информация
- `EXAMPLES.md` — примеры использования
- `Integration.swift` — готовые хуки для интеграции
