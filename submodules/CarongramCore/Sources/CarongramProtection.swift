import Foundation
import TelegramCore
import Postbox

// MARK: - Content Protection Manager

public final class CarongramProtection {
    private let settings: CarongramSettings
    
    public init(settings: CarongramSettings) {
        self.settings = settings
    }
    
    // MARK: Protected Content
    public func canSaveProtectedContent() -> Bool {
        return settings.saveProtectedContent
    }
    
    // MARK: Self-Destructing Content
    public func canSaveSelfDestructingContent() -> Bool {
        return settings.saveSelfDestructingContent
    }
    
    // MARK: Screenshot Notifications
    public func shouldDisableScreenshotNotification() -> Bool {
        return settings.disableScreenshotNotification
    }
    
    // MARK: Black Screen on Screenshot
    public func shouldDisableBlackScreenOnScreenshot() -> Bool {
        return settings.disableBlackScreenOnScreenshot
    }
    
    // MARK: Secret Chat Message Hiding
    public func shouldDisableSecretChatMessageHiding() -> Bool {
        return settings.disableSecretChatMessageHiding
    }
    
    // MARK: Check if message can be saved
    public func canSaveMessage(_ message: Message) -> Bool {
        // Check if message is protected
        if message.containsSecretMedia {
            return canSaveSelfDestructingContent()
        }
        
        // Check if message has copy protection
        if message.isCopyProtected() {
            return canSaveProtectedContent()
        }
        
        return true
    }
}

// MARK: - Message Extension for Protection Checks
extension Message {
    public var containsSecretMedia: Bool {
        for media in self.media {
            if let _ = media as? TelegramMediaImage {
                // Check for self-destruct timer
                return true
            }
            if let _ = media as? TelegramMediaFile {
                return true
            }
        }
        return false
    }
    
    public func isCopyProtected() -> Bool {
        // Check message flags for copy protection
        return self.flags.contains(.CopyProtected)
    }
}

// MARK: - Message Flags Extension
extension Message.Flags {
    public static let CopyProtected = Message.Flags(rawValue: 1 << 27)
}
