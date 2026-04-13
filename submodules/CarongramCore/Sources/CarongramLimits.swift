import Foundation

// MARK: - Carongram Premium Limits Override

public struct CarongramLimits {
    // Standard Telegram limits
    public static let standardMaxFolders = 10
    public static let standardMaxPinnedChats = 5
    public static let standardMaxChatsPerFolder = 100
    
    // Carongram enhanced limits
    public static let carongramMaxFolders = 999
    public static let carongramMaxPinnedChats = 999
    public static let carongramMaxChatsPerFolder = 999
    
    public static func getMaxFolders(settings: CarongramSettings) -> Int {
        return settings.unlimitedFolders ? carongramMaxFolders : standardMaxFolders
    }
    
    public static func getMaxPinnedChats(settings: CarongramSettings) -> Int {
        return settings.unlimitedPinnedChats ? carongramMaxPinnedChats : standardMaxPinnedChats
    }
    
    public static func getMaxChatsPerFolder(settings: CarongramSettings) -> Int {
        return settings.increasedChatsPerFolder ? carongramMaxChatsPerFolder : standardMaxChatsPerFolder
    }
}
