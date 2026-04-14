import Foundation
import SwiftSignalKit
import Postbox

public struct GhostSettings: Codable, Equatable {
    // Логирование
    public var saveDeletedMessages: Bool
    public var saveEditedMessages: Bool
    
    // Режим призрака
    public var hideOnlineStatus: Bool
    public var hideTyping: Bool
    public var hideRecordingVoice: Bool
    public var hideRecordingVideo: Bool
    public var hideUploadingMedia: Bool
    public var hideStickerSelection: Bool
    public var hideReactions: Bool
    public var hideVoiceInGroupCall: Bool
    public var hideLocationSelection: Bool
    public var disableReadReceipts: Bool
    public var disableStoryViews: Bool
    
    // Защита и ограничения
    public var saveProtectedContent: Bool
    public var saveSelfDestructingContent: Bool
    public var disableScreenshotNotification: Bool
    public var disableBlackScreenOnScreenshot: Bool
    public var disableSecretChatMessageHiding: Bool
    
    // Локальный Premium
    public var unlimitedFolders: Bool
    public var unlimitedPinnedChats: Bool
    public var increasedChatLimits: Bool
    public var showPremiumBadge: Bool
    
    public static var `default`: GhostSettings {
        return GhostSettings(
            saveDeletedMessages: false,
            saveEditedMessages: false,
            hideOnlineStatus: false,
            hideTyping: false,
            hideRecordingVoice: false,
            hideRecordingVideo: false,
            hideUploadingMedia: false,
            hideStickerSelection: false,
            hideReactions: false,
            hideVoiceInGroupCall: false,
            hideLocationSelection: false,
            disableReadReceipts: false,
            disableStoryViews: false,
            saveProtectedContent: false,
            saveSelfDestructingContent: false,
            disableScreenshotNotification: false,
            disableBlackScreenOnScreenshot: false,
            disableSecretChatMessageHiding: false,
            unlimitedFolders: false,
            unlimitedPinnedChats: false,
            increasedChatLimits: false,
            showPremiumBadge: false
        )
    }
    
    public init(
        saveDeletedMessages: Bool,
        saveEditedMessages: Bool,
        hideOnlineStatus: Bool,
        hideTyping: Bool,
        hideRecordingVoice: Bool,
        hideRecordingVideo: Bool,
        hideUploadingMedia: Bool,
        hideStickerSelection: Bool,
        hideReactions: Bool,
        hideVoiceInGroupCall: Bool,
        hideLocationSelection: Bool,
        disableReadReceipts: Bool,
        disableStoryViews: Bool,
        saveProtectedContent: Bool,
        saveSelfDestructingContent: Bool,
        disableScreenshotNotification: Bool,
        disableBlackScreenOnScreenshot: Bool,
        disableSecretChatMessageHiding: Bool,
        unlimitedFolders: Bool,
        unlimitedPinnedChats: Bool,
        increasedChatLimits: Bool,
        showPremiumBadge: Bool
    ) {
        self.saveDeletedMessages = saveDeletedMessages
        self.saveEditedMessages = saveEditedMessages
        self.hideOnlineStatus = hideOnlineStatus
        self.hideTyping = hideTyping
        self.hideRecordingVoice = hideRecordingVoice
        self.hideRecordingVideo = hideRecordingVideo
        self.hideUploadingMedia = hideUploadingMedia
        self.hideStickerSelection = hideStickerSelection
        self.hideReactions = hideReactions
        self.hideVoiceInGroupCall = hideVoiceInGroupCall
        self.hideLocationSelection = hideLocationSelection
        self.disableReadReceipts = disableReadReceipts
        self.disableStoryViews = disableStoryViews
        self.saveProtectedContent = saveProtectedContent
        self.saveSelfDestructingContent = saveSelfDestructingContent
        self.disableScreenshotNotification = disableScreenshotNotification
        self.disableBlackScreenOnScreenshot = disableBlackScreenOnScreenshot
        self.disableSecretChatMessageHiding = disableSecretChatMessageHiding
        self.unlimitedFolders = unlimitedFolders
        self.unlimitedPinnedChats = unlimitedPinnedChats
        self.increasedChatLimits = increasedChatLimits
        self.showPremiumBadge = showPremiumBadge
    }
}

private let ghostSettingsKey = ValueBoxKey(length: 8)

public func updateGhostSettings(transaction: Transaction, _ f: (GhostSettings) -> GhostSettings) {
    let current = transaction.getPreferencesEntry(key: PreferencesKeys.ghostSettings) as? GhostSettings ?? .default
    let updated = f(current)
    transaction.setPreferencesEntry(key: PreferencesKeys.ghostSettings, value: updated)
}

public func getGhostSettings(transaction: Transaction) -> GhostSettings {
    return transaction.getPreferencesEntry(key: PreferencesKeys.ghostSettings) as? GhostSettings ?? .default
}

extension PreferencesKeys {
    public static let ghostSettings = PreferencesKey("GhostSettings")
}
