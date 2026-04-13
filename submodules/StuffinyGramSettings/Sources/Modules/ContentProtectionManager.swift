import Foundation
import SwiftSignalKit
import TelegramCore
import Postbox

/// ContentProtectionManager - защищает и сохраняет контент
public final class ContentProtectionManager {
    public static let shared = ContentProtectionManager()
    
    // MARK: - Public Signals
    private let _isEnabled = ValuePromise<Bool>(false)
    public var isEnabled: Signal<Bool, NoError> {
        return _isEnabled.get()
    }
    
    // Protected Content
    private let _allowSaveProtected = ValuePromise<Bool>(false)
    public var allowSaveProtected: Signal<Bool, NoError> {
        return _allowSaveProtected.get()
    }
    
    // Self-destructing Messages
    private let _allowSaveSelfDestructing = ValuePromise<Bool>(false)
    public var allowSaveSelfDestructing: Signal<Bool, NoError> {
        return _allowSaveSelfDestructing.get()
    }
    
    // Screenshot Notifications
    private let _disableScreenshotNotification = ValuePromise<Bool>(false)
    public var disableScreenshotNotification: Signal<Bool, NoError> {
        return _disableScreenshotNotification.get()
    }
    
    // Black Screen on Screenshot
    private let _disableBlackScreen = ValuePromise<Bool>(false)
    public var disableBlackScreen: Signal<Bool, NoError> {
        return _disableBlackScreen.get()
    }
    
    // Secret Chat Screenshot
    private let _disableSecretChatScreenshot = ValuePromise<Bool>(false)
    public var disableSecretChatScreenshot: Signal<Bool, NoError> {
        return _disableSecretChatScreenshot.get()
    }
    
    // Disable Forwards
    private let _preventForwarding = ValuePromise<Bool>(false)
    public var preventForwarding: Signal<Bool, NoError> {
        return _preventForwarding.get()
    }
    
    // Content Protection Statistics
    private let _protectedContentCount = ValuePromise<Int>(0)
    public var protectedContentCount: Signal<Int, NoError> {
        return _protectedContentCount.get()
    }
    
    private let _selfDestructingContentCount = ValuePromise<Int>(0)
    public var selfDestructingContentCount: Signal<Int, NoError> {
        return _selfDestructingContentCount.get()
    }
    
    // MARK: - Private
    private var disposeBag = DisposableSet()
    
    private init() {}
    
    // MARK: - Public Methods
    
    public func initialize() {
        loadState()
    }
    
    public func setEnabled(_ enabled: Bool) {
        _isEnabled.set(enabled)
        saveState()
    }
    
    public func setAllowSaveProtected(_ allow: Bool) {
        _allowSaveProtected.set(allow)
        saveState()
    }
    
    public func setAllowSaveSelfDestructing(_ allow: Bool) {
        _allowSaveSelfDestructing.set(allow)
        saveState()
    }
    
    public func setDisableScreenshotNotification(_ disable: Bool) {
        _disableScreenshotNotification.set(disable)
        saveState()
    }
    
    public func setDisableBlackScreen(_ disable: Bool) {
        _disableBlackScreen.set(disable)
        saveState()
    }
    
    public func setDisableSecretChatScreenshot(_ disable: Bool) {
        _disableSecretChatScreenshot.set(disable)
        saveState()
    }
    
    public func setPreventForwarding(_ prevent: Bool) {
        _preventForwarding.set(prevent)
        saveState()
    }
    
    /// Сохранить защищённый контент
    public func saveProtectedContent(
        media: Media,
        peerId: PeerId,
        messageId: MessageId
    ) -> Signal<Bool, NoError> {
        return .single(StuffinyGramDatabase.shared.saveProtectedContent(
            media: media,
            peerId: peerId,
            messageId: messageId
        ))
    }
    
    /// Сохранить самоуничтожающийся контент
    public func saveSelfDestructingContent(
        media: Media,
        peerId: PeerId,
        messageId: MessageId,
        ttl: Int32
    ) -> Signal<Bool, NoError> {
        return .single(StuffinyGramDatabase.shared.saveSelfDestructingContent(
            media: media,
            peerId: peerId,
            messageId: messageId,
            ttl: ttl
        ))
    }
    
    /// Получить список сохранённого защищённого контента
    public func getProtectedContent() -> Signal<[ProtectedContent], NoError> {
        return .single(StuffinyGramDatabase.shared.getProtectedContent())
    }
    
    /// Получить список сохранённого самоуничтожающегося контента
    public func getSelfDestructingContent() -> Signal<[SelfDestructingContent], NoError> {
        return .single(StuffinyGramDatabase.shared.getSelfDestructingContent())
    }
    
    /// Очистить все сохранённое защищённое содержимое
    public func clearProtectedContent() {
        StuffinyGramDatabase.shared.clearProtectedContent()
        updateStats()
    }
    
    /// Очистить все сохранённое самоуничтожающееся содержимое
    public func clearSelfDestructingContent() {
        StuffinyGramDatabase.shared.clearSelfDestructingContent()
        updateStats()
    }
    
    public func resetToDefaults() {
        _isEnabled.set(false)
        _allowSaveProtected.set(false)
        _allowSaveSelfDestructing.set(false)
        _disableScreenshotNotification.set(false)
        _disableBlackScreen.set(false)
        _disableSecretChatScreenshot.set(false)
        _preventForwarding.set(false)
        saveState()
    }
    
    public func exportSettings() -> [String: Any] {
        return [
            "isEnabled": _isEnabled.get(),
            "allowSaveProtected": _allowSaveProtected.get(),
            "allowSaveSelfDestructing": _allowSaveSelfDestructing.get(),
            "disableScreenshotNotification": _disableScreenshotNotification.get(),
            "disableBlackScreen": _disableBlackScreen.get(),
            "disableSecretChatScreenshot": _disableSecretChatScreenshot.get(),
            "preventForwarding": _preventForwarding.get()
        ]
    }
    
    public func importSettings(_ settings: [String: Any]) {
        if let enabled = settings["isEnabled"] as? Bool { _isEnabled.set(enabled) }
        if let allow = settings["allowSaveProtected"] as? Bool { _allowSaveProtected.set(allow) }
        if let allow = settings["allowSaveSelfDestructing"] as? Bool { _allowSaveSelfDestructing.set(allow) }
        if let disable = settings["disableScreenshotNotification"] as? Bool { _disableScreenshotNotification.set(disable) }
        if let disable = settings["disableBlackScreen"] as? Bool { _disableBlackScreen.set(disable) }
        if let disable = settings["disableSecretChatScreenshot"] as? Bool { _disableSecretChatScreenshot.set(disable) }
        if let prevent = settings["preventForwarding"] as? Bool { _preventForwarding.set(prevent) }
        saveState()
    }
    
    // MARK: - Private Methods
    
    private func loadState() {
        let defaults = UserDefaults(suiteName: "group.stuffinyGram") ?? UserDefaults.standard
        
        _isEnabled.set(defaults.bool(forKey: "ContentProtection_Enabled"))
        _allowSaveProtected.set(defaults.bool(forKey: "ContentProtection_SaveProtected"))
        _allowSaveSelfDestructing.set(defaults.bool(forKey: "ContentProtection_SaveSelfDestructing"))
        _disableScreenshotNotification.set(defaults.bool(forKey: "ContentProtection_DisableScreenshot"))
        _disableBlackScreen.set(defaults.bool(forKey: "ContentProtection_DisableBlackScreen"))
        _disableSecretChatScreenshot.set(defaults.bool(forKey: "ContentProtection_DisableSecretScreenshot"))
        _preventForwarding.set(defaults.bool(forKey: "ContentProtection_PreventForward"))
        
        updateStats()
    }
    
    private func saveState() {
        let defaults = UserDefaults(suiteName: "group.stuffinyGram") ?? UserDefaults.standard
        
        defaults.set(_isEnabled.get(), forKey: "ContentProtection_Enabled")
        defaults.set(_allowSaveProtected.get(), forKey: "ContentProtection_SaveProtected")
        defaults.set(_allowSaveSelfDestructing.get(), forKey: "ContentProtection_SaveSelfDestructing")
        defaults.set(_disableScreenshotNotification.get(), forKey: "ContentProtection_DisableScreenshot")
        defaults.set(_disableBlackScreen.get(), forKey: "ContentProtection_DisableBlackScreen")
        defaults.set(_disableSecretChatScreenshot.get(), forKey: "ContentProtection_DisableSecretScreenshot")
        defaults.set(_preventForwarding.get(), forKey: "ContentProtection_PreventForward")
        defaults.synchronize()
    }
    
    private func updateStats() {
        _protectedContentCount.set(StuffinyGramDatabase.shared.getProtectedContentCount())
        _selfDestructingContentCount.set(StuffinyGramDatabase.shared.getSelfDestructingContentCount())
    }
}

// MARK: - Models

public struct ProtectedContent: Codable, Equatable {
    public let id: String
    public let peerId: Int64
    public let messageId: Int32
    public let mediaType: String
    public let savedAt: Int32
    public let mediaPath: String?
    
    public init(id: String, peerId: Int64, messageId: Int32, mediaType: String, savedAt: Int32, mediaPath: String?) {
        self.id = id
        self.peerId = peerId
        self.messageId = messageId
        self.mediaType = mediaType
        self.savedAt = savedAt
        self.mediaPath = mediaPath
    }
}

public struct SelfDestructingContent: Codable, Equatable {
    public let id: String
    public let peerId: Int64
    public let messageId: Int32
    public let mediaType: String
    public let ttl: Int32
    public let savedAt: Int32
    public let mediaPath: String?
    
    public init(id: String, peerId: Int64, messageId: Int32, mediaType: String, ttl: Int32, savedAt: Int32, mediaPath: String?) {
        self.id = id
        self.peerId = peerId
        self.messageId = messageId
        self.mediaType = mediaType
        self.ttl = ttl
        self.savedAt = savedAt
        self.mediaPath = mediaPath
    }
}
