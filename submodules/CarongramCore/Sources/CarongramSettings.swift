import Foundation
import SwiftSignalKit
import Postbox

// MARK: - Carongram Settings Structure

public struct CarongramSettings: Codable, Equatable {
    // MARK: Logging Settings
    public var saveDeletedMessages: Bool
    public var saveEditedMessages: Bool
    public var clearDeletedMessagesLog: Bool
    
    // MARK: Ghost Mode Settings
    public var hideOnlineStatus: Bool
    public var hideTypingStatus: Bool
    public var hideVoiceRecording: Bool
    public var hideVideoRecording: Bool
    public var hideMediaUploading: Bool
    public var hideStickerSelection: Bool
    public var hideEmojiReactions: Bool
    public var hideVoiceInGroupCall: Bool
    public var hideLocationSelection: Bool
    public var hideContactSelection: Bool
    public var hideGameSelection: Bool
    public var disableReadReceipts: Bool
    public var disableStoryViews: Bool
    
    // MARK: Protection & Restrictions
    public var saveProtectedContent: Bool
    public var saveSelfDestructingContent: Bool
    public var disableScreenshotNotification: Bool
    public var disableBlackScreenOnScreenshot: Bool
    public var disableSecretChatMessageHiding: Bool
    
    // MARK: Local Premium Features
    public var unlimitedFolders: Bool
    public var unlimitedPinnedChats: Bool
    public var increasedChatsPerFolder: Bool
    public var showPremiumBadge: Bool
    
    public static var `default`: CarongramSettings {
        return CarongramSettings(
            // Logging
            saveDeletedMessages: false,
            saveEditedMessages: false,
            clearDeletedMessagesLog: false,
            // Ghost Mode
            hideOnlineStatus: false,
            hideTypingStatus: false,
            hideVoiceRecording: false,
            hideVideoRecording: false,
            hideMediaUploading: false,
            hideStickerSelection: false,
            hideEmojiReactions: false,
            hideVoiceInGroupCall: false,
            hideLocationSelection: false,
            hideContactSelection: false,
            hideGameSelection: false,
            disableReadReceipts: false,
            disableStoryViews: false,
            // Protection
            saveProtectedContent: false,
            saveSelfDestructingContent: false,
            disableScreenshotNotification: false,
            disableBlackScreenOnScreenshot: false,
            disableSecretChatMessageHiding: false,
            // Local Premium
            unlimitedFolders: false,
            unlimitedPinnedChats: false,
            increasedChatsPerFolder: false,
            showPremiumBadge: false
        )
    }
    
    public init(
        saveDeletedMessages: Bool,
        saveEditedMessages: Bool,
        clearDeletedMessagesLog: Bool,
        hideOnlineStatus: Bool,
        hideTypingStatus: Bool,
        hideVoiceRecording: Bool,
        hideVideoRecording: Bool,
        hideMediaUploading: Bool,
        hideStickerSelection: Bool,
        hideEmojiReactions: Bool,
        hideVoiceInGroupCall: Bool,
        hideLocationSelection: Bool,
        hideContactSelection: Bool,
        hideGameSelection: Bool,
        disableReadReceipts: Bool,
        disableStoryViews: Bool,
        saveProtectedContent: Bool,
        saveSelfDestructingContent: Bool,
        disableScreenshotNotification: Bool,
        disableBlackScreenOnScreenshot: Bool,
        disableSecretChatMessageHiding: Bool,
        unlimitedFolders: Bool,
        unlimitedPinnedChats: Bool,
        increasedChatsPerFolder: Bool,
        showPremiumBadge: Bool
    ) {
        self.saveDeletedMessages = saveDeletedMessages
        self.saveEditedMessages = saveEditedMessages
        self.clearDeletedMessagesLog = clearDeletedMessagesLog
        self.hideOnlineStatus = hideOnlineStatus
        self.hideTypingStatus = hideTypingStatus
        self.hideVoiceRecording = hideVoiceRecording
        self.hideVideoRecording = hideVideoRecording
        self.hideMediaUploading = hideMediaUploading
        self.hideStickerSelection = hideStickerSelection
        self.hideEmojiReactions = hideEmojiReactions
        self.hideVoiceInGroupCall = hideVoiceInGroupCall
        self.hideLocationSelection = hideLocationSelection
        self.hideContactSelection = hideContactSelection
        self.hideGameSelection = hideGameSelection
        self.disableReadReceipts = disableReadReceipts
        self.disableStoryViews = disableStoryViews
        self.saveProtectedContent = saveProtectedContent
        self.saveSelfDestructingContent = saveSelfDestructingContent
        self.disableScreenshotNotification = disableScreenshotNotification
        self.disableBlackScreenOnScreenshot = disableBlackScreenOnScreenshot
        self.disableSecretChatMessageHiding = disableSecretChatMessageHiding
        self.unlimitedFolders = unlimitedFolders
        self.unlimitedPinnedChats = unlimitedPinnedChats
        self.increasedChatsPerFolder = increasedChatsPerFolder
        self.showPremiumBadge = showPremiumBadge
    }
}

// MARK: - Settings Manager

public final class CarongramSettingsManager {
    private let preferencesKey = PreferencesKey(name: "CarongramSettings")
    private let postbox: Postbox
    
    public init(postbox: Postbox) {
        self.postbox = postbox
    }
    
    public func get() -> Signal<CarongramSettings, NoError> {
        return postbox.transaction { transaction -> CarongramSettings in
            if let entry = transaction.getPreferencesEntry(key: self.preferencesKey) as? CarongramSettings {
                return entry
            }
            return .default
        }
    }
    
    public func update(_ f: @escaping (CarongramSettings) -> CarongramSettings) -> Signal<Void, NoError> {
        return postbox.transaction { transaction -> Void in
            let current: CarongramSettings
            if let entry = transaction.getPreferencesEntry(key: self.preferencesKey) as? CarongramSettings {
                current = entry
            } else {
                current = .default
            }
            let updated = f(current)
            transaction.setPreferencesEntry(key: self.preferencesKey, value: updated)
        }
    }
}

// MARK: - Deleted Messages Storage

public struct DeletedMessage: Codable, Equatable {
    public let messageId: MessageId
    public let peerId: PeerId
    public let text: String
    public let timestamp: Int32
    public let author: PeerId?
    public let media: [String]
    
    public init(messageId: MessageId, peerId: PeerId, text: String, timestamp: Int32, author: PeerId?, media: [String]) {
        self.messageId = messageId
        self.peerId = peerId
        self.text = text
        self.timestamp = timestamp
        self.author = author
        self.media = media
    }
}

public struct EditedMessage: Codable, Equatable {
    public let messageId: MessageId
    public let peerId: PeerId
    public let originalText: String
    public let editedText: String
    public let editTimestamp: Int32
    
    public init(messageId: MessageId, peerId: PeerId, originalText: String, editedText: String, editTimestamp: Int32) {
        self.messageId = messageId
        self.peerId = peerId
        self.originalText = originalText
        self.editedText = editedText
        self.editTimestamp = editTimestamp
    }
}
