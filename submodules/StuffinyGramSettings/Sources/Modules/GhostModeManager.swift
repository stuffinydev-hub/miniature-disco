import Foundation
import SwiftSignalKit
import TelegramCore
import Postbox

/// GhostModeManager - скрывает активность пользователя
public final class GhostModeManager {
    public static let shared = GhostModeManager()
    
    // MARK: - Public Signals
    private let _isEnabled = ValuePromise<Bool>(false)
    public var isEnabled: Signal<Bool, NoError> {
        return _isEnabled.get()
    }
    
    // Online Status
    private let _hideOnlineStatus = ValuePromise<Bool>(false)
    public var hideOnlineStatus: Signal<Bool, NoError> {
        return _hideOnlineStatus.get()
    }
    
    // Typing Indicators
    private let _hideTypingStatus = ValuePromise<Bool>(false)
    public var hideTypingStatus: Signal<Bool, NoError> {
        return _hideTypingStatus.get()
    }
    
    private let _hideRecordingStatus = ValuePromise<Bool>(false)
    public var hideRecordingStatus: Signal<Bool, NoError> {
        return _hideRecordingStatus.get()
    }
    
    // Media Upload
    private let _hideMediaUpload = ValuePromise<Bool>(false)
    public var hideMediaUpload: Signal<Bool, NoError> {
        return _hideMediaUpload.get()
    }
    
    // Message Reactions
    private let _hideEmojiReactions = ValuePromise<Bool>(false)
    public var hideEmojiReactions: Signal<Bool, NoError> {
        return _hideEmojiReactions.get()
    }
    
    // Read Receipts
    private let _disableReadReceipts = ValuePromise<Bool>(false)
    public var disableReadReceipts: Signal<Bool, NoError> {
        return _disableReadReceipts.get()
    }
    
    // Story Views
    private let _hideStoryViews = ValuePromise<Bool>(false)
    public var hideStoryViews: Signal<Bool, NoError> {
        return _hideStoryViews.get()
    }
    
    // Voice in Calls (experimental)
    private let _hideVoiceInCalls = ValuePromise<Bool>(false)
    public var hideVoiceInCalls: Signal<Bool, NoError> {
        return _hideVoiceInCalls.get()
    }
    
    // Location Sharing (experimental)
    private let _hideLocationSharing = ValuePromise<Bool>(false)
    public var hideLocationSharing: Signal<Bool, NoError> {
        return _hideLocationSharing.get()
    }
    
    private let _hideContactSharing = ValuePromise<Bool>(false)
    public var hideContactSharing: Signal<Bool, NoError> {
        return _hideContactSharing.get()
    }
    
    // Games
    private let _hideGameActivity = ValuePromise<Bool>(false)
    public var hideGameActivity: Signal<Bool, NoError> {
        return _hideGameActivity.get()
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
        if !enabled {
            // Отключить все подопции при отключении режима
            disableAllFeatures()
        }
        saveState()
    }
    
    public func setHideOnlineStatus(_ hide: Bool) {
        _hideOnlineStatus.set(hide)
        saveState()
    }
    
    public func setHideTypingStatus(_ hide: Bool) {
        _hideTypingStatus.set(hide)
        saveState()
    }
    
    public func setHideRecordingStatus(_ hide: Bool) {
        _hideRecordingStatus.set(hide)
        saveState()
    }
    
    public func setHideMediaUpload(_ hide: Bool) {
        _hideMediaUpload.set(hide)
        saveState()
    }
    
    public func setHideEmojiReactions(_ hide: Bool) {
        _hideEmojiReactions.set(hide)
        saveState()
    }
    
    public func setDisableReadReceipts(_ disable: Bool) {
        _disableReadReceipts.set(disable)
        saveState()
    }
    
    public func setHideStoryViews(_ hide: Bool) {
        _hideStoryViews.set(hide)
        saveState()
    }
    
    public func setHideVoiceInCalls(_ hide: Bool) {
        _hideVoiceInCalls.set(hide)
        saveState()
    }
    
    public func setHideLocationSharing(_ hide: Bool) {
        _hideLocationSharing.set(hide)
        saveState()
    }
    
    public func setHideContactSharing(_ hide: Bool) {
        _hideContactSharing.set(hide)
        saveState()
    }
    
    public func setHideGameActivity(_ hide: Bool) {
        _hideGameActivity.set(hide)
        saveState()
    }
    
    /// Проверить, активен ли режим призрака
    public func isGhostModeActive() -> Bool {
        return _isEnabled.get()
    }
    
    /// Включить все функции скрытия
    public func enableAllFeatures() {
        _hideOnlineStatus.set(true)
        _hideTypingStatus.set(true)
        _hideRecordingStatus.set(true)
        _hideMediaUpload.set(true)
        _hideEmojiReactions.set(true)
        _disableReadReceipts.set(true)
        _hideStoryViews.set(true)
        _hideVoiceInCalls.set(true)
        _hideLocationSharing.set(true)
        _hideContactSharing.set(true)
        _hideGameActivity.set(true)
        saveState()
    }
    
    /// Отключить все функции скрытия
    public func disableAllFeatures() {
        _hideOnlineStatus.set(false)
        _hideTypingStatus.set(false)
        _hideRecordingStatus.set(false)
        _hideMediaUpload.set(false)
        _hideEmojiReactions.set(false)
        _disableReadReceipts.set(false)
        _hideStoryViews.set(false)
        _hideVoiceInCalls.set(false)
        _hideLocationSharing.set(false)
        _hideContactSharing.set(false)
        _hideGameActivity.set(false)
        saveState()
    }
    
    public func resetToDefaults() {
        setEnabled(false)
        disableAllFeatures()
    }
    
    public func exportSettings() -> [String: Any] {
        return [
            "isEnabled": _isEnabled.get(),
            "hideOnlineStatus": _hideOnlineStatus.get(),
            "hideTypingStatus": _hideTypingStatus.get(),
            "hideRecordingStatus": _hideRecordingStatus.get(),
            "hideMediaUpload": _hideMediaUpload.get(),
            "hideEmojiReactions": _hideEmojiReactions.get(),
            "disableReadReceipts": _disableReadReceipts.get(),
            "hideStoryViews": _hideStoryViews.get(),
            "hideVoiceInCalls": _hideVoiceInCalls.get(),
            "hideLocationSharing": _hideLocationSharing.get(),
            "hideContactSharing": _hideContactSharing.get(),
            "hideGameActivity": _hideGameActivity.get()
        ]
    }
    
    public func importSettings(_ settings: [String: Any]) {
        if let enabled = settings["isEnabled"] as? Bool {
            _isEnabled.set(enabled)
        }
        if let hide = settings["hideOnlineStatus"] as? Bool { _hideOnlineStatus.set(hide) }
        if let hide = settings["hideTypingStatus"] as? Bool { _hideTypingStatus.set(hide) }
        if let hide = settings["hideRecordingStatus"] as? Bool { _hideRecordingStatus.set(hide) }
        if let hide = settings["hideMediaUpload"] as? Bool { _hideMediaUpload.set(hide) }
        if let hide = settings["hideEmojiReactions"] as? Bool { _hideEmojiReactions.set(hide) }
        if let disable = settings["disableReadReceipts"] as? Bool { _disableReadReceipts.set(disable) }
        if let hide = settings["hideStoryViews"] as? Bool { _hideStoryViews.set(hide) }
        if let hide = settings["hideVoiceInCalls"] as? Bool { _hideVoiceInCalls.set(hide) }
        if let hide = settings["hideLocationSharing"] as? Bool { _hideLocationSharing.set(hide) }
        if let hide = settings["hideContactSharing"] as? Bool { _hideContactSharing.set(hide) }
        if let hide = settings["hideGameActivity"] as? Bool { _hideGameActivity.set(hide) }
        saveState()
    }
    
    // MARK: - Private Methods
    
    private func loadState() {
        let defaults = UserDefaults(suiteName: "group.stuffinyGram") ?? UserDefaults.standard
        
        _isEnabled.set(defaults.bool(forKey: "GhostMode_Enabled"))
        _hideOnlineStatus.set(defaults.bool(forKey: "GhostMode_HideOnline"))
        _hideTypingStatus.set(defaults.bool(forKey: "GhostMode_HideTyping"))
        _hideRecordingStatus.set(defaults.bool(forKey: "GhostMode_HideRecording"))
        _hideMediaUpload.set(defaults.bool(forKey: "GhostMode_HideMedia"))
        _hideEmojiReactions.set(defaults.bool(forKey: "GhostMode_HideReactions"))
        _disableReadReceipts.set(defaults.bool(forKey: "GhostMode_DisableRead"))
        _hideStoryViews.set(defaults.bool(forKey: "GhostMode_HideStory"))
        _hideVoiceInCalls.set(defaults.bool(forKey: "GhostMode_HideVoice"))
        _hideLocationSharing.set(defaults.bool(forKey: "GhostMode_HideLocation"))
        _hideContactSharing.set(defaults.bool(forKey: "GhostMode_HideContact"))
        _hideGameActivity.set(defaults.bool(forKey: "GhostMode_HideGame"))
    }
    
    private func saveState() {
        let defaults = UserDefaults(suiteName: "group.stuffinyGram") ?? UserDefaults.standard
        
        defaults.set(_isEnabled.get(), forKey: "GhostMode_Enabled")
        defaults.set(_hideOnlineStatus.get(), forKey: "GhostMode_HideOnline")
        defaults.set(_hideTypingStatus.get(), forKey: "GhostMode_HideTyping")
        defaults.set(_hideRecordingStatus.get(), forKey: "GhostMode_HideRecording")
        defaults.set(_hideMediaUpload.get(), forKey: "GhostMode_HideMedia")
        defaults.set(_hideEmojiReactions.get(), forKey: "GhostMode_HideReactions")
        defaults.set(_disableReadReceipts.get(), forKey: "GhostMode_DisableRead")
        defaults.set(_hideStoryViews.get(), forKey: "GhostMode_HideStory")
        defaults.set(_hideVoiceInCalls.get(), forKey: "GhostMode_HideVoice")
        defaults.set(_hideLocationSharing.get(), forKey: "GhostMode_HideLocation")
        defaults.set(_hideContactSharing.get(), forKey: "GhostMode_HideContact")
        defaults.set(_hideGameActivity.get(), forKey: "GhostMode_HideGame")
        defaults.synchronize()
    }
}
