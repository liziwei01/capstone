//
//  Client.swift
//  iChat
//
//  Created by 李子为 on 9/29/23.
//

import SwiftUI
import SQLite3

class ChatClient {
    var db: OpaquePointer?
    
    init() {
        open()
        createSessionTable()
        createMessageTable()
    }
    
    // 打开数据库连接
    private func open() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("chat.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        }
    }
    
    // 创建会话表
    private func createSessionTable() {
        let createSessionTableSQL = """
            CREATE TABLE IF NOT EXISTS tb_chat_session (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                secret_key TEXT,
                nickname TEXT,
                db_time INTEGER
            );
        """
        if ExecRaw(createSessionTableSQL) != SQLITE_OK {
            print("Error creating session table")
        }
    }
    
    // 创建消息表
    private func createMessageTable() {
        let createMessageTableSQL = """
            CREATE TABLE IF NOT EXISTS tb_chat_message (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id INTEGER,
                message TEXT,
                db_time INTEGER,
                FOREIGN KEY (session_id) REFERENCES tb_chat_session (id)
            );
        """
        if ExecRaw(createMessageTableSQL) != SQLITE_OK {
            print("Error creating message table")
        }
    }
    
    // 执行SQL语句
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
    
    // 获取会话列表
    func GetSessions() -> [ChatSession] {
        var sessions: [ChatSession] = []

        let querySessionsSQL = "SELECT * FROM tb_chat_session;"
        if let statement = prepareStatement(sql: querySessionsSQL) {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
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

    // 获取消息列表
    func GetMessages(sessionID: Int) -> [ChatMessage] {
        var messages: [ChatMessage] = []

        let queryMessagesSQL = "SELECT id, message, db_time FROM tb_chat_message WHERE session_id = ?;"
        if let statement = prepareStatement(sql: queryMessagesSQL) {
            sqlite3_bind_int(statement, 1, Int32(sessionID))
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let message = String(cString: sqlite3_column_text(statement, 1))
                let dbTime = Int64(sqlite3_column_int64(statement, 2))
                let chatMessage = ChatMessage(id: id, sessionID: sessionID, message: message, dbTime: dbTime)
                messages.append(chatMessage)
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing statement for getting messages")
        }

        return messages
    }

    
    // 添加会话
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
    
    // 插入消息
    func InsertMessage(sessionID: Int, message: String, dbTime: Int64) {
        let insertMessageSQL = """
            INSERT INTO tb_chat_message (session_id, db_time, message)
            VALUES (?, ?, ?);
        """
        if let statement = prepareStatement(sql: insertMessageSQL) {
            sqlite3_bind_int(statement, 1, Int32(sessionID))
            sqlite3_bind_int64(statement, 2, dbTime)
            sqlite3_bind_text(statement, 3, (message as NSString).utf8String, Int32(message.utf8.count), nil)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error inserting message")
            }
            
            sqlite3_finalize(statement)
        } else {
            print("Error preparing statement for inserting message")
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
    
    // 准备SQL语句
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

struct ChatSession: Identifiable  {
    let id: Int
    let secretKey: String
    let nickname: String
    let dbTime: Int64
}

struct ChatMessage: Identifiable  {
    let id: Int
    let sessionID: Int
    let message: String
    let dbTime: Int64
}

var client: ChatClient = ChatClient()
