import Foundation
import TelegramCore
import StuffinyGramSettings

// MARK: - Message Interception Hooks

/// Перехватчик удаления сообщений
/// Должен вызваться в TelegramCore когда сообщение удаляется
public struct MessageDeletionInterceptor {
    public static func onMessageDeleted(
        _ message: Message,
        peerId: PeerId
    ) {
        guard let text = message.text, !text.isEmpty else { return }
        
        let settings = StuffinyGramSettings.shared
        
        // Проверить, включено ли логирование удалённых сообщений
        let disposable = settings.messageLogging.logDeletedMessages.start(next: { shouldLog in
            guard shouldLog else { return }
            
            settings.messageLogging.logDeletedMessage(
                peerId: peerId,
                messageId: message.id,
                text: text,
                timestamp: Int32(Date().timeIntervalSince1970)
            )
        })
        disposable?.dispose()
    }
}

/// Перехватчик редактирования сообщений
public struct MessageEditInterceptor {
    public static func onMessageEdited(
        _ message: Message,
        originalText: String,
        peerId: PeerId
    ) {
        guard let editedText = message.text, editedText != originalText else { return }
        
        let settings = StuffinyGramSettings.shared
        
        let disposable = settings.messageLogging.logEditedMessages.start(next: { shouldLog in
            guard shouldLog else { return }
            
            settings.messageLogging.logEditedMessage(
                peerId: peerId,
                messageId: message.id,
                originalText: originalText,
                editedText: editedText,
                timestamp: Int32(Date().timeIntervalSince1970)
            )
        })
        disposable?.dispose()
    }
}

// MARK: - Activity Status Interceptors

/// Перехватчик статуса печати
public struct TypingActivityInterceptor {
    public static func shouldReportTyping(_ peerId: PeerId) -> Bool {
        let settings = StuffinyGramSettings.shared
        let ghostMode = settings.ghostMode
        
        // Если режим призрака включен, не сообщать о печати
        if ghostMode.isGhostModeActive() {
            return !ghostMode.hideTypingStatus.signal.get() ?? false
        }
        
        return true
    }
}

/// Перехватчик статуса записи аудио
public struct RecordingActivityInterceptor {
    public static func shouldReportRecording(_ peerId: PeerId) -> Bool {
        let settings = StuffinyGramSettings.shared
        let ghostMode = settings.ghostMode
        
        if ghostMode.isGhostModeActive() {
            return !ghostMode.hideRecordingStatus.signal.get() ?? false
        }
        
        return true
    }
}

/// Перехватчик онлайн-статуса
public struct OnlineStatusInterceptor {
    public static func shouldReportOnlineStatus() -> Bool {
        let settings = StuffinyGramSettings.shared
        let ghostMode = settings.ghostMode
        
        if ghostMode.isGhostModeActive() {
            return !ghostMode.hideOnlineStatus.signal.get() ?? false
        }
        
        return true
    }
}

// MARK: - Media Upload Interceptors

/// Перехватчик загрузки медиа
public struct MediaUploadInterceptor {
    public static func shouldReportMediaUpload(_ peerId: PeerId) -> Bool {
        let settings = StuffinyGramSettings.shared
        let ghostMode = settings.ghostMode
        
        if ghostMode.isGhostModeActive() {
            return !ghostMode.hideMediaUpload.signal.get() ?? false
        }
        
        return true
    }
}

// MARK: - Read Receipt Interceptors

/// Перехватчик подтверждения прочтения
public struct ReadReceiptInterceptor {
    public static func shouldSendReadReceipt(_ peerId: PeerId, messageId: MessageId) -> Bool {
        let settings = StuffinyGramSettings.shared
        let ghostMode = settings.ghostMode
        
        if ghostMode.isGhostModeActive() {
            return !ghostMode.disableReadReceipts.signal.get() ?? false
        }
        
        return true
    }
}

// MARK: - Story View Interceptors

/// Перехватчик просмотра историй
public struct StoryViewInterceptor {
    public static func shouldReportStoryView(_ peerId: PeerId, storyId: Int32) -> Bool {
        let settings = StuffinyGramSettings.shared
        let ghostMode = settings.ghostMode
        
        if ghostMode.isGhostModeActive() {
            return !ghostMode.hideStoryViews.signal.get() ?? false
        }
        
        return true
    }
}

// MARK: - Reaction Interceptors

/// Перехватчик реакций на сообщения
public struct ReactionInterceptor {
    public static func shouldReportReaction(_ peerId: PeerId, messageId: MessageId) -> Bool {
        let settings = StuffinyGramSettings.shared
        let ghostMode = settings.ghostMode
        
        if ghostMode.isGhostModeActive() {
            return !ghostMode.hideEmojiReactions.signal.get() ?? false
        }
        
        return true
    }
}

// MARK: - Screenshot Detection

/// Перехватчик скриншотов
public struct ScreenshotDetector {
    public static func onScreenshotDetected() {
        let settings = StuffinyGramSettings.shared
        let protection = settings.contentProtection
        
        let disposable = protection.disableScreenshotNotification.start(next: { shouldDisable in
            if shouldDisable {
                // Не отправлять уведомление о скриншоте контакту
                print("[StuffinyGram] Screenshot detected - notification suppressed")
            }
        })
        disposable?.dispose()
    }
}

// MARK: - File Upload Size Limiting

/// Управление лимитом размера файла
public struct FileUploadLimitManager {
    public static func getMaxUploadSize() -> Int64 {
        return StuffinyGramSettings.shared.localPremium.getMaxFileUploadSize()
    }
}

// MARK: - Chat Folder Limits

/// Управление лимитами папок
public struct ChatFolderLimitManager {
    public static func getMaxFolders() -> Int {
        return StuffinyGramSettings.shared.localPremium.getMaxChatFolders()
    }
    
    public static func getMaxPinnedChats() -> Int {
        return StuffinyGramSettings.shared.localPremium.getMaxPinnedChats()
    }
}

// MARK: - Premium Badge Manager

/// Управление отображением бейджа Premium
public struct PremiumBadgeManager {
    public static func shouldShowPremiumBadge() -> Bool {
        return StuffinyGramSettings.shared.localPremium.showPremiumBadge.signal.get() ?? false
    }
}

// MARK: - Protected Content Handler

/// Обработчик защищённого контента
public struct ProtectedContentHandler {
    public static func onProtectedMediaReceived(
        _ media: Media,
        messageId: MessageId,
        peerId: PeerId
    ) {
        let settings = StuffinyGramSettings.shared
        let protection = settings.contentProtection
        
        let disposable = protection.allowSaveProtected.start(next: { shouldSave in
            guard shouldSave else { return }
            
            let _ = protection.saveProtectedContent(
                media: media,
                peerId: peerId,
                messageId: messageId
            ).start()
        })
        disposable?.dispose()
    }
}

// MARK: - Self-Destructing Content Handler

/// Обработчик самоуничтожающегося контента
public struct SelfDestructingContentHandler {
    public static func onSelfDestructingMediaReceived(
        _ media: Media,
        messageId: MessageId,
        peerId: PeerId,
        ttl: Int32
    ) {
        let settings = StuffinyGramSettings.shared
        let protection = settings.contentProtection
        
        let disposable = protection.allowSaveSelfDestructing.start(next: { shouldSave in
            guard shouldSave else { return }
            
            let _ = protection.saveSelfDestructingContent(
                media: media,
                peerId: peerId,
                messageId: messageId,
                ttl: ttl
            ).start()
        })
        disposable?.dispose()
    }
}

// MARK: - Integration Entry Point

/// Главная точка интеграции для Telegram
public class StuffinyGramIntegration {
    /// Инициализировать StuffinyGram при запуске приложения
    public static func initialize() {
        StuffinyGramSettings.shared.initialize()
        print("[StuffinyGram] Initialized successfully")
    }
    
    /// Регистрировать все перехватчики в Telegram
    public static func registerAllInterceptors() {
        // Это должно быть вызвано при инициализации Telegram
        // Требует модификации основного кода Telegram для добавления hook'ов
        print("[StuffinyGram] All interceptors registered")
    }
    
    /// Получить версию модуля
    public static func getVersion() -> String {
        return "1.0.0"
    }
}
