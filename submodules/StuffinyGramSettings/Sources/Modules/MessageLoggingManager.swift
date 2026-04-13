import Foundation
import SwiftSignalKit
import TelegramCore
import Postbox

/// MessageLoggingManager - логирует удалённые и отредактированные сообщения
public final class MessageLoggingManager {
    public static let shared = MessageLoggingManager()
    
    // MARK: - Public Signals
    private let _isEnabled = ValuePromise<Bool>(false)
    public var isEnabled: Signal<Bool, NoError> {
        return _isEnabled.get()
    }
    
    private let _logDeletedMessages = ValuePromise<Bool>(false)
    public var logDeletedMessages: Signal<Bool, NoError> {
        return _logDeletedMessages.get()
    }
    
    private let _logEditedMessages = ValuePromise<Bool>(false)
    public var logEditedMessages: Signal<Bool, NoError> {
        return _logEditedMessages.get()
    }
    
    private let _auto_clearOldLogs = ValuePromise<Bool>(false)
    public var autoClearOldLogs: Signal<Bool, NoError> {
        return _auto_clearOldLogs.get()
    }
    
    private let _clearOlderThanDays = ValuePromise<Int>(30)
    public var clearOlderThanDays: Signal<Int, NoError> {
        return _clearOlderThanDays.get()
    }
    
    private let _logCount = ValuePromise<Int>(0)
    public var logCount: Signal<Int, NoError> {
        return _logCount.get()
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
    
    public func setLogDeletedMessages(_ log: Bool) {
        _logDeletedMessages.set(log)
        saveState()
    }
    
    public func setLogEditedMessages(_ log: Bool) {
        _logEditedMessages.set(log)
        saveState()
    }
    
    public func setAutoClearOldLogs(_ enabled: Bool) {
        _auto_clearOldLogs.set(enabled)
        saveState()
    }
    
    public func setClearOlderThanDays(_ days: Int) {
        _clearOlderThanDays.set(days)
        saveState()
    }
    
    /// Добавить лог удаленного сообщения
    public func logDeletedMessage(
        peerId: PeerId,
        messageId: MessageId,
        text: String,
        timestamp: Int32 = Int32(Date().timeIntervalSince1970)
    ) {
        StuffinyGramDatabase.shared.addDeletedMessageLog(
            peerId: peerId,
            messageId: messageId,
            text: text,
            timestamp: timestamp
        )
        updateLogCount()
    }
    
    /// Добавить лог отредактированного сообщения
    public func logEditedMessage(
        peerId: PeerId,
        messageId: MessageId,
        originalText: String,
        editedText: String,
        timestamp: Int32 = Int32(Date().timeIntervalSince1970)
    ) {
        StuffinyGramDatabase.shared.addEditedMessageLog(
            peerId: peerId,
            messageId: messageId,
            originalText: originalText,
            editedText: editedText,
            timestamp: timestamp
        )
        updateLogCount()
    }
    
    /// Получить все логи удаленных сообщений
    public func getDeletedMessagesLogs() -> Signal<[DeletedMessageLog], NoError> {
        return .single(StuffinyGramDatabase.shared.getDeletedMessageLogs())
    }
    
    /// Получить все логи отредактированных сообщений
    public func getEditedMessagesLogs() -> Signal<[EditedMessageLog], NoError> {
        return .single(StuffinyGramDatabase.shared.getEditedMessageLogs())
    }
    
    /// Очистить все логи
    public func clearAllLogs() {
        StuffinyGramDatabase.shared.clearAllMessageLogs()
        updateLogCount()
    }
    
    /// Удалить логи старше N дней
    public func clearLogsOlderThanDays(_ days: Int) {
        StuffinyGramDatabase.shared.clearMessageLogsOlderThan(days: days)
        updateLogCount()
    }
    
    public func resetToDefaults() {
        _isEnabled.set(false)
        _logDeletedMessages.set(false)
        _logEditedMessages.set(false)
        _auto_clearOldLogs.set(false)
        _clearOlderThanDays.set(30)
        saveState()
    }
    
    public func exportSettings() -> [String: Any] {
        return [
            "isEnabled": _isEnabled.get() as Any,
            "logDeletedMessages": _logDeletedMessages.get() as Any,
            "logEditedMessages": _logEditedMessages.get() as Any,
            "autoClearOldLogs": _auto_clearOldLogs.get() as Any,
            "clearOlderThanDays": _clearOlderThanDays.get() as Any
        ]
    }
    
    public func importSettings(_ settings: [String: Any]) {
        if let enabled = settings["isEnabled"] as? Bool {
            _isEnabled.set(enabled)
        }
        if let logDeleted = settings["logDeletedMessages"] as? Bool {
            _logDeletedMessages.set(logDeleted)
        }
        if let logEdited = settings["logEditedMessages"] as? Bool {
            _logEditedMessages.set(logEdited)
        }
        if let autoClear = settings["autoClearOldLogs"] as? Bool {
            _auto_clearOldLogs.set(autoClear)
        }
        if let days = settings["clearOlderThanDays"] as? Int {
            _clearOlderThanDays.set(days)
        }
        saveState()
    }
    
    // MARK: - Private Methods
    
    private func loadState() {
        let defaults = UserDefaults(suiteName: "group.stuffinyGram") ?? UserDefaults.standard
        
        _isEnabled.set(defaults.bool(forKey: "MessageLogging_Enabled"))
        _logDeletedMessages.set(defaults.bool(forKey: "MessageLogging_LogDeleted"))
        _logEditedMessages.set(defaults.bool(forKey: "MessageLogging_LogEdited"))
        _auto_clearOldLogs.set(defaults.bool(forKey: "MessageLogging_AutoClear"))
        _clearOlderThanDays.set(defaults.integer(forKey: "MessageLogging_ClearDays") > 0 ? defaults.integer(forKey: "MessageLogging_ClearDays") : 30)
        
        updateLogCount()
    }
    
    private func saveState() {
        let defaults = UserDefaults(suiteName: "group.stuffinyGram") ?? UserDefaults.standard
        
        defaults.set(_isEnabled.get(), forKey: "MessageLogging_Enabled")
        defaults.set(_logDeletedMessages.get(), forKey: "MessageLogging_LogDeleted")
        defaults.set(_logEditedMessages.get(), forKey: "MessageLogging_LogEdited")
        defaults.set(_auto_clearOldLogs.get(), forKey: "MessageLogging_AutoClear")
        defaults.set(_clearOlderThanDays.get(), forKey: "MessageLogging_ClearDays")
        defaults.synchronize()
    }
    
    private func updateLogCount() {
        let count = StuffinyGramDatabase.shared.getMessageLogsCount()
        _logCount.set(count)
    }
}

// MARK: - Models

public struct DeletedMessageLog: Codable, Equatable {
    public let peerId: Int64
    public let messageId: Int32
    public let text: String
    public let deletedAt: Int32
    
    public init(peerId: Int64, messageId: Int32, text: String, deletedAt: Int32) {
        self.peerId = peerId
        self.messageId = messageId
        self.text = text
        self.deletedAt = deletedAt
    }
}

public struct EditedMessageLog: Codable, Equatable {
    public let peerId: Int64
    public let messageId: Int32
    public let originalText: String
    public let editedText: String
    public let editedAt: Int32
    
    public init(peerId: Int64, messageId: Int32, originalText: String, editedText: String, editedAt: Int32) {
        self.peerId = peerId
        self.messageId = messageId
        self.originalText = originalText
        self.editedText = editedText
        self.editedAt = editedAt
    }
}
