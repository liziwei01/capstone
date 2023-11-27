//
//  Client.swift
//  iChat
//
//  Created by 李子为 on 9/29/23.
//

import SwiftUI
import SQLite3

protocol ChatDatabaseObserver: AnyObject {
    func messagesUpdated(sessionID: Int32)
}

class ChatClient {
    var db: OpaquePointer?
    
    private var observers: [ChatDatabaseObserver] = []

    func addObserver(_ observer: ChatDatabaseObserver) {
        observers.append(observer)
    }

    func removeObserver(_ observer: ChatDatabaseObserver) {
        observers = observers.filter { $0 !== observer }
    }

    private func notifyObservers(sessionID: Int32) {
        for observer in observers {
            observer.messagesUpdated(sessionID: sessionID)
        }
    }
    
    init() {
        open()
        deleteSessionTable()
        deleteMessgaeTable()
        createSessionTable()
        createMessageTable()
    }
    
    // Open database connection
    private func open() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("chat.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        }
    }
    
    // Create session table
    private func createSessionTable() {
        let createSessionTableSQL = """
            CREATE TABLE IF NOT EXISTS tb_chat_session (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                secret_key TEXT DEFAULT '',
                nickname TEXT DEFAULT '',
                db_time INTEGER DEFAULT 0
            );
        """
        if ExecRaw(createSessionTableSQL) != SQLITE_OK {
            print("Error creating session table")
        }
    }
    
    // Create message table
    private func createMessageTable() {
        let createMessageTableSQL = """
            CREATE TABLE IF NOT EXISTS tb_chat_message (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id INTEGER NOT NULL,
                is_user BOOLEAN DEFAULT FALSE,
                nickname TEXT DEFAULT '',
                message TEXT DEFAULT '',
                db_time INTEGER DEFAULT 0,
                FOREIGN KEY (session_id) REFERENCES tb_chat_session (id)
            );
        """
        if ExecRaw(createMessageTableSQL) != SQLITE_OK {
            print("Error creating message table")
        }
    }
    
    // execute raw sql
    func ExecRaw(_ sql: String) -> Int32 {
        var errorMessage: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, sql, nil, nil, &errorMessage) != SQLITE_OK {
            if let error = errorMessage {
                print("Error executing SQL: \(String(cString: error))")
            }
            return SQLITE_ERROR
        }
        return SQLITE_OK
    }
    
    // Get all the sessions
    func GetSessions() -> [ChatSession] {
        var sessions: [ChatSession] = []

        let querySessionsSQL = "SELECT * FROM tb_chat_session;"
        if let statement = prepareStatement(sql: querySessionsSQL) {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int32(sqlite3_column_int(statement, 0))
                let secretKey = String(cString: sqlite3_column_text(statement, 1))
                let nickname = String(cString: sqlite3_column_text(statement, 2))
                let dbTime = Int64(sqlite3_column_int64(statement, 3))
                let session = ChatSession(id: id, secretKey: secretKey, nickname: nickname, dbTime: dbTime)
                sessions.append(session)
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing statement for getting sessions")
        }

        return sessions
    }

    // Get messages list by sessionid
    func GetMessages(sessionID: Int32) -> [ChatMessage] {
        var messages: [ChatMessage] = []

        let queryMessagesSQL = "SELECT id, is_user, nickname, message, db_time FROM tb_chat_message WHERE session_id = ?;"
        if let statement = prepareStatement(sql: queryMessagesSQL) {
            sqlite3_bind_int(statement, 1, Int32(sessionID))
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let isUser = sqlite3_column_int(statement, 1) != 0
                let nickname = String(cString: sqlite3_column_text(statement, 2))
                let message = String(cString: sqlite3_column_text(statement, 3))
                let dbTime = Int64(sqlite3_column_int64(statement, 4))
                let chatMessage = ChatMessage(id: id, isUser: isUser, sessionID: sessionID, nickname: nickname, message: message, dbTime: dbTime)
                messages.append(chatMessage)
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing statement for getting messages")
        }

        return messages
    }
    
    // Get the latest local chat time
    func GetLatestChatTime(sessionID: Int32) -> Int64 {
        // This SQL query selects the most recent dbTime for the specified sessionID
        let queryLatestTimeSQL = "SELECT MAX(db_time) FROM tb_chat_message WHERE session_id = ?;"
        
        // Prepare the statement and bind the sessionID
        if let statement = prepareStatement(sql: queryLatestTimeSQL) {
            sqlite3_bind_int(statement, 1, sessionID)
            
            // If there is a result, get the maximum dbTime
            if sqlite3_step(statement) == SQLITE_ROW {
                let maxTime = sqlite3_column_int64(statement, 0)
                sqlite3_finalize(statement)
                return maxTime
            } else {
                sqlite3_finalize(statement)
                print("No message found for session \(sessionID). Returning default time.")
                return 0  // You can default to another value if needed
            }
        } else {
            print("Error preparing statement for getting the latest chat time.")
            return 0  // Default value in case of error
        }
    }

    
    // Add a session
    func AddSession(secretKey: String, nickname: String, dbTime: Int64) {
        let insertSessionSQL = """
            INSERT INTO tb_chat_session (secret_key, nickname, db_time)
            VALUES (?, ?, ?);
        """
        if let statement = prepareStatement(sql: insertSessionSQL) {
            sqlite3_bind_text(statement, 1, (secretKey as NSString).utf8String, Int32(secretKey.utf8.count), nil)
            sqlite3_bind_text(statement, 2, (nickname as NSString).utf8String, Int32(nickname.utf8.count), nil)
            sqlite3_bind_int64(statement, 3, dbTime)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failure inserting: \(errmsg)")
            }
            
            sqlite3_finalize(statement)
        } else {
            print("Error preparing statement for adding session")
        }
    }
    
    // Insert a message
    func InsertMessage(sessionID: Int32, isUser: Bool, nickname: String, message: String, dbTime: Int64) {
        let insertMessageSQL = """
            INSERT INTO tb_chat_message (session_id, is_user, nickname, message, db_time)
            VALUES (?, ?, ?, ?, ?);
        """
        if let statement = prepareStatement(sql: insertMessageSQL) {
            sqlite3_bind_int(statement, 1, sessionID)
            sqlite3_bind_int(statement, 2, isUser ? 1 : 0)
            sqlite3_bind_text(statement, 3, (nickname as NSString).utf8String, Int32(nickname.utf8.count), nil)
            sqlite3_bind_text(statement, 4, (message as NSString).utf8String, Int32(message.utf8.count), nil)
            sqlite3_bind_int64(statement, 5, dbTime)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error inserting message")
            }
            
            sqlite3_finalize(statement)
        } else {
            print("Error preparing statement for inserting message")
        }
        notifyObservers(sessionID: sessionID)
    }
    
    // Delete sessions and related messages
    func DeleteSession(sessionID: Int32) {
        // Delete the messages associated with the session
        let deleteMessagesSQL = "DELETE FROM tb_chat_message WHERE session_id = ?;"
        if let statement = prepareStatement(sql: deleteMessagesSQL) {
            sqlite3_bind_int(statement, 1, sessionID)
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error deleting associated messages")
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing statement for deleting messages")
        }
        
        // Delete the session itself
        let deleteSessionSQL = "DELETE FROM tb_chat_session WHERE id = ?;"
        if let statement = prepareStatement(sql: deleteSessionSQL) {
            sqlite3_bind_int(statement, 1, sessionID)
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error deleting session")
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing statement for deleting session")
        }
        
    }

    
    // Clear all data from tb_chat_session table
    func ClearSessionTable() {
        let clearSessionSQL = "DELETE FROM tb_chat_session;"
        if ExecRaw(clearSessionSQL) != SQLITE_OK {
            print("Error clearing session table")
        }
    }

    // Clear all data from tb_chat_message table
    func ClearMessageTable() {
        let clearMessageSQL = "DELETE FROM tb_chat_message;"
        if ExecRaw(clearMessageSQL) != SQLITE_OK {
            print("Error clearing message table")
        }
    }
    
    // Delete session table
    private func deleteSessionTable() {
        let deleteSessionTableSQL = """
            DROP TABLE IF EXISTS tb_chat_session;
        """
        if ExecRaw(deleteSessionTableSQL) != SQLITE_OK {
            print("Error deleting session table")
        }
    }
    
    // Delete session table
    private func deleteMessgaeTable() {
        let deleteSessionTableSQL = """
            DROP TABLE IF EXISTS tb_chat_message;
        """
        if ExecRaw(deleteSessionTableSQL) != SQLITE_OK {
            print("Error deleting session table")
        }
    }

    
    // Prepare SQL statement
    private func prepareStatement(sql: String) -> OpaquePointer? {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            print("Error preparing SQL statement")
            return nil
        }
        return statement
    }
    
    deinit {
        sqlite3_close(db)
    }
}

struct ChatSession: Identifiable, Hashable  {
    let id: Int32
    let secretKey: String
    let nickname: String
    let dbTime: Int64
}

// Must be Hashable so we can put ChatMessages into ForEach
struct ChatMessage: Identifiable, Hashable  {
    let id: Int
    let isUser: Bool
    let sessionID: Int32
    let nickname: String
    let message: String
    let dbTime: Int64
}

var client: ChatClient = ChatClient()
