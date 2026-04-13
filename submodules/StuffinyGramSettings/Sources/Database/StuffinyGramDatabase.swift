import Foundation
import SQLite3
import TelegramCore

/// StuffinyGramDatabase - база данных для хранения логов и контента
public final class StuffinyGramDatabase {
    public static let shared = StuffinyGramDatabase()
    
    private let databasePath: String
    private var database: OpaquePointer?
    private let queue = DispatchQueue(label: "com.stuffinyGram.database", attributes: .concurrent)
    
    private init() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let appGroupPath = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.stuffinyGram")
        let basePath = appGroupPath ?? documentDirectory
        
        databasePath = basePath.appendingPathComponent("StuffinyGram.db").path
        
        // Create or open database
        openDatabase()
        createTables()
    }
    
    // MARK: - Database Setup
    
    private func openDatabase() {
        let cString = databasePath.cString(using: .utf8)!
        if sqlite3_open(cString, &database) == SQLITE_OK {
            // Enable WAL mode for better concurrency
            sqlite3_exec(database, "PRAGMA journal_mode=WAL;", nil, nil, nil)
        }
    }
    
    private func createTables() {
        let createDeletedMessagesTable = """
        CREATE TABLE IF NOT EXISTS deleted_messages (
            id TEXT PRIMARY KEY,
            peer_id INTEGER NOT NULL,
            message_id INTEGER NOT NULL,
            text TEXT NOT NULL,
            deleted_at INTEGER NOT NULL,
            created_at INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX IF NOT EXISTS idx_deleted_peer ON deleted_messages(peer_id);
        CREATE INDEX IF NOT EXISTS idx_deleted_time ON deleted_messages(deleted_at);
        """
        
        let createEditedMessagesTable = """
        CREATE TABLE IF NOT EXISTS edited_messages (
            id TEXT PRIMARY KEY,
            peer_id INTEGER NOT NULL,
            message_id INTEGER NOT NULL,
            original_text TEXT NOT NULL,
            edited_text TEXT NOT NULL,
            edited_at INTEGER NOT NULL,
            created_at INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX IF NOT EXISTS idx_edited_peer ON edited_messages(peer_id);
        CREATE INDEX IF NOT EXISTS idx_edited_time ON edited_messages(edited_at);
        """
        
        let createProtectedContentsTable = """
        CREATE TABLE IF NOT EXISTS protected_contents (
            id TEXT PRIMARY KEY,
            peer_id INTEGER NOT NULL,
            message_id INTEGER NOT NULL,
            media_type TEXT NOT NULL,
            saved_at INTEGER NOT NULL,
            media_path TEXT,
            created_at INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX IF NOT EXISTS idx_protected_peer ON protected_contents(peer_id);
        CREATE INDEX IF NOT EXISTS idx_protected_time ON protected_contents(saved_at);
        """
        
        let createSelfDestructingTable = """
        CREATE TABLE IF NOT EXISTS self_destructing_contents (
            id TEXT PRIMARY KEY,
            peer_id INTEGER NOT NULL,
            message_id INTEGER NOT NULL,
            media_type TEXT NOT NULL,
            ttl INTEGER NOT NULL,
            saved_at INTEGER NOT NULL,
            media_path TEXT,
            created_at INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX IF NOT EXISTS idx_selfdestructing_peer ON self_destructing_contents(peer_id);
        CREATE INDEX IF NOT EXISTS idx_selfdestructing_time ON self_destructing_contents(saved_at);
        """
        
        executeUpdate(createDeletedMessagesTable)
        executeUpdate(createEditedMessagesTable)
        executeUpdate(createProtectedContentsTable)
        executeUpdate(createSelfDestructingTable)
    }
    
    // MARK: - Deleted Messages
    
    public func addDeletedMessageLog(
        peerId: PeerId,
        messageId: MessageId,
        text: String,
        timestamp: Int32
    ) {
        let id = UUID().uuidString
        let query = """
        INSERT INTO deleted_messages (id, peer_id, message_id, text, deleted_at)
        VALUES (?, ?, ?, ?, ?);
        """
        
        queue.async(flags: .barrier) { [weak self] in
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(self?.database, query, -1, &statement, nil) == SQLITE_OK else { return }
            
            sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int64(statement, 2, peerId.toInt64())
            sqlite3_bind_int64(statement, 3, Int64(messageId.id))
            sqlite3_bind_text(statement, 4, text, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 5, timestamp)
            
            sqlite3_step(statement)
            sqlite3_finalize(statement)
        }
    }
    
    public func getDeletedMessageLogs() -> [DeletedMessageLog] {
        var logs: [DeletedMessageLog] = []
        let query = "SELECT peer_id, message_id, text, deleted_at FROM deleted_messages ORDER BY deleted_at DESC;"
        
        queue.sync {
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else { return }
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let peerId = sqlite3_column_int64(statement, 0)
                let messageId = sqlite3_column_int32(statement, 1)
                let text = String(cString: sqlite3_column_text(statement, 2))
                let deletedAt = sqlite3_column_int(statement, 3)
                
                logs.append(DeletedMessageLog(
                    peerId: peerId,
                    messageId: messageId,
                    text: text,
                    deletedAt: deletedAt
                ))
            }
            
            sqlite3_finalize(statement)
        }
        
        return logs
    }
    
    // MARK: - Edited Messages
    
    public func addEditedMessageLog(
        peerId: PeerId,
        messageId: MessageId,
        originalText: String,
        editedText: String,
        timestamp: Int32
    ) {
        let id = UUID().uuidString
        let query = """
        INSERT INTO edited_messages (id, peer_id, message_id, original_text, edited_text, edited_at)
        VALUES (?, ?, ?, ?, ?, ?);
        """
        
        queue.async(flags: .barrier) { [weak self] in
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(self?.database, query, -1, &statement, nil) == SQLITE_OK else { return }
            
            sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int64(statement, 2, peerId.toInt64())
            sqlite3_bind_int64(statement, 3, Int64(messageId.id))
            sqlite3_bind_text(statement, 4, originalText, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, editedText, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 6, timestamp)
            
            sqlite3_step(statement)
            sqlite3_finalize(statement)
        }
    }
    
    public func getEditedMessageLogs() -> [EditedMessageLog] {
        var logs: [EditedMessageLog] = []
        let query = "SELECT peer_id, message_id, original_text, edited_text, edited_at FROM edited_messages ORDER BY edited_at DESC;"
        
        queue.sync {
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else { return }
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let peerId = sqlite3_column_int64(statement, 0)
                let messageId = sqlite3_column_int32(statement, 1)
                let original = String(cString: sqlite3_column_text(statement, 2))
                let edited = String(cString: sqlite3_column_text(statement, 3))
                let editedAt = sqlite3_column_int(statement, 4)
                
                logs.append(EditedMessageLog(
                    peerId: peerId,
                    messageId: messageId,
                    originalText: original,
                    editedText: edited,
                    editedAt: editedAt
                ))
            }
            
            sqlite3_finalize(statement)
        }
        
        return logs
    }
    
    // MARK: - Protected Contents
    
    public func saveProtectedContent(
        media: Media,
        peerId: PeerId,
        messageId: MessageId
    ) -> Bool {
        let id = UUID().uuidString
        let query = """
        INSERT INTO protected_contents (id, peer_id, message_id, media_type, saved_at)
        VALUES (?, ?, ?, ?, ?);
        """
        
        var success = false
        queue.async(flags: .barrier) { [weak self] in
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(self?.database, query, -1, &statement, nil) == SQLITE_OK else { return }
            
            sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int64(statement, 2, peerId.toInt64())
            sqlite3_bind_int64(statement, 3, Int64(messageId.id))
            sqlite3_bind_text(statement, 4, "protected", -1, SQLITE_STATIC)
            sqlite3_bind_int(statement, 5, Int32(Date().timeIntervalSince1970))
            
            success = sqlite3_step(statement) == SQLITE_DONE
            sqlite3_finalize(statement)
        }
        
        return success
    }
    
    public func getProtectedContent() -> [ProtectedContent] {
        var contents: [ProtectedContent] = []
        let query = "SELECT id, peer_id, message_id, media_type, saved_at FROM protected_contents ORDER BY saved_at DESC;"
        
        queue.sync {
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else { return }
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let peerId = sqlite3_column_int64(statement, 1)
                let messageId = sqlite3_column_int32(statement, 2)
                let mediaType = String(cString: sqlite3_column_text(statement, 3))
                let savedAt = sqlite3_column_int(statement, 4)
                
                contents.append(ProtectedContent(
                    id: id,
                    peerId: peerId,
                    messageId: messageId,
                    mediaType: mediaType,
                    savedAt: savedAt,
                    mediaPath: nil
                ))
            }
            
            sqlite3_finalize(statement)
        }
        
        return contents
    }
    
    public func getProtectedContentCount() -> Int {
        return getCount(table: "protected_contents")
    }
    
    public func clearProtectedContent() {
        executeUpdate("DELETE FROM protected_contents;")
    }
    
    // MARK: - Self-Destructing Contents
    
    public func saveSelfDestructingContent(
        media: Media,
        peerId: PeerId,
        messageId: MessageId,
        ttl: Int32
    ) -> Bool {
        let id = UUID().uuidString
        let query = """
        INSERT INTO self_destructing_contents (id, peer_id, message_id, media_type, ttl, saved_at)
        VALUES (?, ?, ?, ?, ?, ?);
        """
        
        var success = false
        queue.async(flags: .barrier) { [weak self] in
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(self?.database, query, -1, &statement, nil) == SQLITE_OK else { return }
            
            sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int64(statement, 2, peerId.toInt64())
            sqlite3_bind_int64(statement, 3, Int64(messageId.id))
            sqlite3_bind_text(statement, 4, "selfdestructing", -1, SQLITE_STATIC)
            sqlite3_bind_int(statement, 5, ttl)
            sqlite3_bind_int(statement, 6, Int32(Date().timeIntervalSince1970))
            
            success = sqlite3_step(statement) == SQLITE_DONE
            sqlite3_finalize(statement)
        }
        
        return success
    }
    
    public func getSelfDestructingContent() -> [SelfDestructingContent] {
        var contents: [SelfDestructingContent] = []
        let query = "SELECT id, peer_id, message_id, media_type, ttl, saved_at FROM self_destructing_contents ORDER BY saved_at DESC;"
        
        queue.sync {
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else { return }
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let peerId = sqlite3_column_int64(statement, 1)
                let messageId = sqlite3_column_int32(statement, 2)
                let mediaType = String(cString: sqlite3_column_text(statement, 3))
                let ttl = sqlite3_column_int(statement, 4)
                let savedAt = sqlite3_column_int(statement, 5)
                
                contents.append(SelfDestructingContent(
                    id: id,
                    peerId: peerId,
                    messageId: messageId,
                    mediaType: mediaType,
                    ttl: ttl,
                    savedAt: savedAt,
                    mediaPath: nil
                ))
            }
            
            sqlite3_finalize(statement)
        }
        
        return contents
    }
    
    public func getSelfDestructingContentCount() -> Int {
        return getCount(table: "self_destructing_contents")
    }
    
    public func clearSelfDestructingContent() {
        executeUpdate("DELETE FROM self_destructing_contents;")
    }
    
    // MARK: - Message Logs
    
    public func getMessageLogsCount() -> Int {
        return getCount(table: "deleted_messages") + getCount(table: "edited_messages")
    }
    
    public func clearAllMessageLogs() {
        executeUpdate("DELETE FROM deleted_messages;")
        executeUpdate("DELETE FROM edited_messages;")
    }
    
    public func clearMessageLogsOlderThan(days: Int) {
        let timestamp = Int32(Date().timeIntervalSince1970) - Int32(days * 86400)
        let query = """
        DELETE FROM deleted_messages WHERE deleted_at < ?;
        DELETE FROM edited_messages WHERE edited_at < ?;
        """
        
        queue.async(flags: .barrier) { [weak self] in
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(self?.database, query, -1, &statement, nil) == SQLITE_OK else { return }
            
            sqlite3_bind_int(statement, 1, timestamp)
            sqlite3_bind_int(statement, 2, timestamp)
            
            sqlite3_step(statement)
            sqlite3_finalize(statement)
        }
    }
    
    // MARK: - Utility Methods
    
    private func getCount(table: String) -> Int {
        var count = 0
        let query = "SELECT COUNT(*) FROM \(table);"
        
        queue.sync {
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else { return }
            
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
            
            sqlite3_finalize(statement)
        }
        
        return count
    }
    
    private func executeUpdate(_ sql: String) {
        queue.async(flags: .barrier) { [weak self] in
            var errorMessage: UnsafeMutablePointer<Int8>?
            sqlite3_exec(self?.database, sql, nil, nil, &errorMessage)
            
            if let error = errorMessage {
                let message = String(cString: error)
                print("SQLite Error: \(message)")
                sqlite3_free(errorMessage)
            }
        }
    }
    
    deinit {
        if let db = database {
            sqlite3_close(db)
        }
    }
}
