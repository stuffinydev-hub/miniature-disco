import Foundation
import SwiftSignalKit
import TelegramCore
import Postbox

/// LocalPremiumManager - управляет локальными премиум-функциями
public final class LocalPremiumManager {
    public static let shared = LocalPremiumManager()
    
    // MARK: - Public Signals
    private let _isPremiumEnabled = ValuePromise<Bool>(false)
    public var isPremiumEnabled: Signal<Bool, NoError> {
        return _isPremiumEnabled.get()
    }
    
    // Chat Folder Limits
    private let _unlimitedChatFolders = ValuePromise<Bool>(false)
    public var unlimitedChatFolders: Signal<Bool, NoError> {
        return _unlimitedChatFolders.get()
    }
    
    // Pinned Chats
    private let _unlimitedPinnedChats = ValuePromise<Bool>(false)
    public var unlimitedPinnedChats: Signal<Bool, NoError> {
        return _unlimitedPinnedChats.get()
    }
    
    // Chat Per Folder
    private let _chatsPerFolder = ValuePromise<Int>(100)
    public var chatsPerFolder: Signal<Int, NoError> {
        return _chatsPerFolder.get()
    }
    
    // Custom Status
    private let _customStatusEnabled = ValuePromise<Bool>(false)
    public var customStatusEnabled: Signal<Bool, NoError> {
        return _customStatusEnabled.get()
    }
    
    // Show Premium Badge
    private let _showPremiumBadge = ValuePromise<Bool>(false)
    public var showPremiumBadge: Signal<Bool, NoError> {
        return _showPremiumBadge.get()
    }
    
    // Larger File Upload
    private let _largerFileUpload = ValuePromise<Bool>(false)
    public var largerFileUpload: Signal<Bool, NoError> {
        return _largerFileUpload.get()
    }
    
    // Channel Boosters
    private let _channelBoostersEnabled = ValuePromise<Bool>(false)
    public var channelBoostersEnabled: Signal<Bool, NoError> {
        return _channelBoostersEnabled.get()
    }
    
    // Animated Avatar
    private let _animatedAvatarEnabled = ValuePromise<Bool>(false)
    public var animatedAvatarEnabled: Signal<Bool, NoError> {
        return _animatedAvatarEnabled.get()
    }
    
    // More Saved Gifs
    private let _moreSavedGifs = ValuePromise<Bool>(false)
    public var moreSavedGifs: Signal<Bool, NoError> {
        return _moreSavedGifs.get()
    }
    
    // MARK: - Private
    private var disposeBag = DisposableSet()
    
    private init() {}
    
    // MARK: - Public Methods
    
    public func initialize() {
        loadState()
    }
    
    public func setPremiumEnabled(_ enabled: Bool) {
        _isPremiumEnabled.set(enabled)
        saveState()
    }
    
    public func setUnlimitedChatFolders(_ unlimited: Bool) {
        _unlimitedChatFolders.set(unlimited)
        if unlimited {
            _chatsPerFolder.set(Int.max)
        }
        saveState()
    }
    
    public func setUnlimitedPinnedChats(_ unlimited: Bool) {
        _unlimitedPinnedChats.set(unlimited)
        saveState()
    }
    
    public func setChatsPerFolder(_ count: Int) {
        _chatsPerFolder.set(count)
        saveState()
    }
    
    public func setCustomStatusEnabled(_ enabled: Bool) {
        _customStatusEnabled.set(enabled)
        saveState()
    }
    
    public func setShowPremiumBadge(_ show: Bool) {
        _showPremiumBadge.set(show)
        saveState()
    }
    
    public func setLargerFileUpload(_ enabled: Bool) {
        _largerFileUpload.set(enabled)
        saveState()
    }
    
    public func setChannelBoostersEnabled(_ enabled: Bool) {
        _channelBoostersEnabled.set(enabled)
        saveState()
    }
    
    public func setAnimatedAvatarEnabled(_ enabled: Bool) {
        _animatedAvatarEnabled.set(enabled)
        saveState()
    }
    
    public func setMoreSavedGifs(_ enabled: Bool) {
        _moreSavedGifs.set(enabled)
        saveState()
    }
    
    /// Получить максимальный размер файла для загрузки
    public func getMaxFileUploadSize() -> Int64 {
        return _largerFileUpload.get() ? 4_000_000_000 : 2_000_000_000  // 4GB vs 2GB
    }
    
    /// Получить максимальное количество папок
    public func getMaxChatFolders() -> Int {
        return _unlimitedChatFolders.get() ? Int.max : 10
    }
    
    /// Получить максимальное количество закреплённых чатов
    public func getMaxPinnedChats() -> Int {
        return _unlimitedPinnedChats.get() ? Int.max : 5
    }
    
    /// Получить максимальное количество сохранённых GIF
    public func getMaxSavedGifs() -> Int {
        return _moreSavedGifs.get() ? 400 : 200
    }
    
    /// Включить все премиум-функции
    public func enableAllPremiumFeatures() {
        _unlimitedChatFolders.set(true)
        _unlimitedPinnedChats.set(true)
        _chatsPerFolder.set(Int.max)
        _customStatusEnabled.set(true)
        _showPremiumBadge.set(true)
        _largerFileUpload.set(true)
        _channelBoostersEnabled.set(true)
        _animatedAvatarEnabled.set(true)
        _moreSavedGifs.set(true)
        _isPremiumEnabled.set(true)
        saveState()
    }
    
    /// Отключить все премиум-функции
    public func disableAllPremiumFeatures() {
        _unlimitedChatFolders.set(false)
        _unlimitedPinnedChats.set(false)
        _chatsPerFolder.set(100)
        _customStatusEnabled.set(false)
        _showPremiumBadge.set(false)
        _largerFileUpload.set(false)
        _channelBoostersEnabled.set(false)
        _animatedAvatarEnabled.set(false)
        _moreSavedGifs.set(false)
        _isPremiumEnabled.set(false)
        saveState()
    }
    
    public func resetToDefaults() {
        disableAllPremiumFeatures()
    }
    
    public func exportSettings() -> [String: Any] {
        return [
            "isPremiumEnabled": _isPremiumEnabled.get(),
            "unlimitedChatFolders": _unlimitedChatFolders.get(),
            "unlimitedPinnedChats": _unlimitedPinnedChats.get(),
            "chatsPerFolder": _chatsPerFolder.get(),
            "customStatusEnabled": _customStatusEnabled.get(),
            "showPremiumBadge": _showPremiumBadge.get(),
            "largerFileUpload": _largerFileUpload.get(),
            "channelBoostersEnabled": _channelBoostersEnabled.get(),
            "animatedAvatarEnabled": _animatedAvatarEnabled.get(),
            "moreSavedGifs": _moreSavedGifs.get()
        ]
    }
    
    public func importSettings(_ settings: [String: Any]) {
        if let enabled = settings["isPremiumEnabled"] as? Bool { _isPremiumEnabled.set(enabled) }
        if let unlimited = settings["unlimitedChatFolders"] as? Bool { _unlimitedChatFolders.set(unlimited) }
        if let unlimited = settings["unlimitedPinnedChats"] as? Bool { _unlimitedPinnedChats.set(unlimited) }
        if let count = settings["chatsPerFolder"] as? Int { _chatsPerFolder.set(count) }
        if let enabled = settings["customStatusEnabled"] as? Bool { _customStatusEnabled.set(enabled) }
        if let show = settings["showPremiumBadge"] as? Bool { _showPremiumBadge.set(show) }
        if let enabled = settings["largerFileUpload"] as? Bool { _largerFileUpload.set(enabled) }
        if let enabled = settings["channelBoostersEnabled"] as? Bool { _channelBoostersEnabled.set(enabled) }
        if let enabled = settings["animatedAvatarEnabled"] as? Bool { _animatedAvatarEnabled.set(enabled) }
        if let enabled = settings["moreSavedGifs"] as? Bool { _moreSavedGifs.set(enabled) }
        saveState()
    }
    
    // MARK: - Private Methods
    
    private func loadState() {
        let defaults = UserDefaults(suiteName: "group.stuffinyGram") ?? UserDefaults.standard
        
        _isPremiumEnabled.set(defaults.bool(forKey: "LocalPremium_Enabled"))
        _unlimitedChatFolders.set(defaults.bool(forKey: "LocalPremium_UnlimitedFolders"))
        _unlimitedPinnedChats.set(defaults.bool(forKey: "LocalPremium_UnlimitedPinned"))
        _chatsPerFolder.set(defaults.integer(forKey: "LocalPremium_ChatsPerFolder") > 0 ? defaults.integer(forKey: "LocalPremium_ChatsPerFolder") : 100)
        _customStatusEnabled.set(defaults.bool(forKey: "LocalPremium_CustomStatus"))
        _showPremiumBadge.set(defaults.bool(forKey: "LocalPremium_ShowBadge"))
        _largerFileUpload.set(defaults.bool(forKey: "LocalPremium_LargerFile"))
        _channelBoostersEnabled.set(defaults.bool(forKey: "LocalPremium_Boosters"))
        _animatedAvatarEnabled.set(defaults.bool(forKey: "LocalPremium_AnimatedAvatar"))
        _moreSavedGifs.set(defaults.bool(forKey: "LocalPremium_MoreGifs"))
    }
    
    private func saveState() {
        let defaults = UserDefaults(suiteName: "group.stuffinyGram") ?? UserDefaults.standard
        
        defaults.set(_isPremiumEnabled.get(), forKey: "LocalPremium_Enabled")
        defaults.set(_unlimitedChatFolders.get(), forKey: "LocalPremium_UnlimitedFolders")
        defaults.set(_unlimitedPinnedChats.get(), forKey: "LocalPremium_UnlimitedPinned")
        defaults.set(_chatsPerFolder.get(), forKey: "LocalPremium_ChatsPerFolder")
        defaults.set(_customStatusEnabled.get(), forKey: "LocalPremium_CustomStatus")
        defaults.set(_showPremiumBadge.get(), forKey: "LocalPremium_ShowBadge")
        defaults.set(_largerFileUpload.get(), forKey: "LocalPremium_LargerFile")
        defaults.set(_channelBoostersEnabled.get(), forKey: "LocalPremium_Boosters")
        defaults.set(_animatedAvatarEnabled.get(), forKey: "LocalPremium_AnimatedAvatar")
        defaults.set(_moreSavedGifs.get(), forKey: "LocalPremium_MoreGifs")
        defaults.synchronize()
    }
}
