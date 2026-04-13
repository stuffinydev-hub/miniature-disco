import Foundation
import TelegramCore
import Postbox
import SwiftSignalKit

// MARK: - Message Logger

public final class CarongramLogger {
    private let postbox: Postbox
    private let settings: CarongramSettings
    private let deletedMessagesKey = PreferencesKey(name: "CarongramDeletedMessages")
    private let editedMessagesKey = PreferencesKey(name: "CarongramEditedMessages")
    
    public init(postbox: Postbox, settings: CarongramSettings) {
        self.postbox = postbox
        self.settings = settings
    }
    
    // MARK: Save Deleted Message
    public func logDeletedMessage(_ message: Message) -> Signal<Void, NoError> {
        guard settings.saveDeletedMessages else {
            return .complete()
        }
        
        return postbox.transaction { transaction -> Void in
            var deletedMessages = self.getDeletedMessages(transaction: transaction)
            
            let deletedMessage = DeletedMessage(
                messageId: message.id,
                peerId: message.id.peerId,
                text: message.text,
                timestamp: message.timestamp,
                author: message.author?.id,
                media: message.media.map { String(describing: type(of: $0)) }
            )
            
            deletedMessages.append(deletedMessage)
            
            // Keep only last 1000 deleted messages
            if deletedMessages.count > 1000 {
                deletedMessages = Array(deletedMessages.suffix(1000))
            }
            
            transaction.setPreferencesEntry(key: self.deletedMessagesKey, value: deletedMessages)
        }
    }
    
    // MARK: Save Edited Message
    public func logEditedMessage(original: Message, edited: Message) -> Signal<Void, NoError> {
        guard settings.saveEditedMessages else {
            return .complete()
        }
        
        return postbox.transaction { transaction -> Void in
            var editedMessages = self.getEditedMessages(transaction: transaction)
            
            let editedMessage = EditedMessage(
                messageId: edited.id,
                peerId: edited.id.peerId,
                originalText: original.text,
                editedText: edited.text,
                editTimestamp: edited.timestamp
            )
            
            editedMessages.append(editedMessage)
            
            // Keep only last 1000 edited messages
            if editedMessages.count > 1000 {
                editedMessages = Array(editedMessages.suffix(1000))
            }
            
            transaction.setPreferencesEntry(key: self.editedMessagesKey, value: editedMessages)
        }
    }
    
    // MARK: Get Deleted Messages
    public func getDeletedMessages() -> Signal<[DeletedMessage], NoError> {
        return postbox.transaction { transaction -> [DeletedMessage] in
            return self.getDeletedMessages(transaction: transaction)
        }
    }
    
    private func getDeletedMessages(transaction: Transaction) -> [DeletedMessage] {
        if let messages = transaction.getPreferencesEntry(key: deletedMessagesKey) as? [DeletedMessage] {
            return messages
        }
        return []
    }
    
    // MARK: Get Edited Messages
    public func getEditedMessages() -> Signal<[EditedMessage], NoError> {
        return postbox.transaction { transaction -> [EditedMessage] in
            return self.getEditedMessages(transaction: transaction)
        }
    }
    
    private func getEditedMessages(transaction: Transaction) -> [EditedMessage] {
        if let messages = transaction.getPreferencesEntry(key: editedMessagesKey) as? [EditedMessage] {
            return messages
        }
        return []
    }
    
    // MARK: Clear Logs
    public func clearDeletedMessages() -> Signal<Void, NoError> {
        return postbox.transaction { transaction -> Void in
            transaction.setPreferencesEntry(key: self.deletedMessagesKey, value: [DeletedMessage]())
        }
    }
    
    public func clearEditedMessages() -> Signal<Void, NoError> {
        return postbox.transaction { transaction -> Void in
            transaction.setPreferencesEntry(key: self.editedMessagesKey, value: [EditedMessage]())
        }
    }
    
    public func clearAllLogs() -> Signal<Void, NoError> {
        return clearDeletedMessages()
        |> then(clearEditedMessages())
    }
}
