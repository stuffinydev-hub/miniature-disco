import Foundation
import TelegramCore
import Postbox
import SwiftSignalKit

// MARK: - Ghost Mode Manager

public final class CarongramGhostMode {
    private let settings: CarongramSettings
    
    public init(settings: CarongramSettings) {
        self.settings = settings
    }
    
    // MARK: Online Status
    public func shouldHideOnlineStatus() -> Bool {
        return settings.hideOnlineStatus
    }
    
    // MARK: Typing Indicators
    public func shouldHideTyping() -> Bool {
        return settings.hideTypingStatus
    }
    
    public func shouldHideVoiceRecording() -> Bool {
        return settings.hideVoiceRecording
    }
    
    public func shouldHideVideoRecording() -> Bool {
        return settings.hideVideoRecording
    }
    
    // MARK: Media Upload Status
    public func shouldHideMediaUploading() -> Bool {
        return settings.hideMediaUploading
    }
    
    // MARK: Sticker Selection
    public func shouldHideStickerSelection() -> Bool {
        return settings.hideStickerSelection
    }
    
    // MARK: Emoji Reactions
    public func shouldHideEmojiReactions() -> Bool {
        return settings.hideEmojiReactions
    }
    
    // MARK: Group Call Voice
    public func shouldHideVoiceInGroupCall() -> Bool {
        return settings.hideVoiceInGroupCall
    }
    
    // MARK: Location/Contact/Game Selection
    public func shouldHideLocationSelection() -> Bool {
        return settings.hideLocationSelection
    }
    
    public func shouldHideContactSelection() -> Bool {
        return settings.hideContactSelection
    }
    
    public func shouldHideGameSelection() -> Bool {
        return settings.hideGameSelection
    }
    
    // MARK: Read Receipts
    public func shouldDisableReadReceipts() -> Bool {
        return settings.disableReadReceipts
    }
    
    // MARK: Story Views
    public func shouldDisableStoryViews() -> Bool {
        return settings.disableStoryViews
    }
    
    // MARK: Combined Check for Typing Activities
    public func shouldBlockTypingActivity(type: SendMessageTypingAction) -> Bool {
        switch type {
        case .typing:
            return shouldHideTyping()
        case .recordingVoice:
            return shouldHideVoiceRecording()
        case .recordingInstantVideo:
            return shouldHideVideoRecording()
        case .uploadingPhoto, .uploadingVideo, .uploadingFile:
            return shouldHideMediaUploading()
        case .choosingSticker:
            return shouldHideStickerSelection()
        case .choosingLocation:
            return shouldHideLocationSelection()
        case .choosingContact:
            return shouldHideContactSelection()
        case .playingGame:
            return shouldHideGameSelection()
        default:
            return false
        }
    }
}

// MARK: - Typing Action Enum Extension
public enum SendMessageTypingAction {
    case typing
    case recordingVoice
    case recordingInstantVideo
    case uploadingPhoto
    case uploadingVideo
    case uploadingFile
    case choosingSticker
    case choosingLocation
    case choosingContact
    case playingGame
}
