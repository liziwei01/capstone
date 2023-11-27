//
//  iChatTests.swift
//  iChatTests
//
//  Created by 李子为 on 9/17/23.
//

import XCTest
@testable import iChat
import SQLite3

final class iChatTests: XCTestCase {
    
    var chatClient: ChatClient!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        // Create an instance of ChatClient before each test case is run
        chatClient = ChatClient()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        // Destroy the instance of ChatClient after each test case runs
        chatClient = nil
        super.tearDown()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testAESEncryptionDecryption() throws {
        // Given
        let originalString = "This is a string to encrypt"
        let keyString = "thisisaverysecurekey123456789012"
        guard let encryptedString = AESEncryptWithString(input: originalString, key: keyString) else {
            XCTFail("Encryption failed")
            return
        }
        
        // When
        guard let decryptedString = AESDecryptWithString(input: encryptedString, key: keyString) else {
            XCTFail("Decryption failed")
            return
        }
        
        // Then
        XCTAssertEqual(originalString, decryptedString, "Decrypted string should equal original string")
    }
    
    // Test the creation of a session and retrieval of sessions.
    func testAddSessionAndGetSessions() throws {
        let secretKey = "TestSecretKey"
        let nickname = "TestUser"
        let dbTime: Int64 = Int64(Date().timeIntervalSince1970)
        
        chatClient.ClearSessionTable()

        chatClient.AddSession(secretKey: secretKey, nickname: nickname, dbTime: dbTime)

        let sessions = chatClient.GetSessions()

        XCTAssertTrue(sessions.count > 0, "Sessions should not be empty after adding a session")
    }
    
    // Test the insertion of a message and retrieval of messages for a session.
    func testInsertMessageAndGetMessages() throws {
        let secretKey = "TestSecretKey"
        let nickname = "TestUser"
        let dbTime: Int64 = Int64(Date().timeIntervalSince1970)
        
        let message = "Hello, world!"
        
        chatClient.AddSession(secretKey: secretKey, nickname: nickname, dbTime: dbTime)
        let sessions = chatClient.GetSessions()
        guard let session = sessions.last else {
            XCTFail("No session found")
            return
        }
        
        chatClient.ClearMessageTable()

        chatClient.InsertMessage(sessionID: session.id, isUser: true, nickname: "123", message: message, dbTime: dbTime)

        let messages = chatClient.GetMessages(sessionID: session.id)

        XCTAssertTrue(messages.count > 0, "Messages should not be empty after inserting a message")
        XCTAssertEqual(messages.last?.message, message, "Inserted message should match the retrieved message")
    }
    
	func testGetAction() throws {
        let chatSessionSecretKey = "testSecretKey2"
		let contentsDict = GetChatAPI(secretKey: chatSessionSecretKey, lastTime: 12345)
        print(contentsDict)
	}

    func testSendAction() throws {
        let chatSessionSecretKey = "testSecretKey2"
        let currentMessage = "Test Message5"
        
        let now = Now()
        
        let response = SendChatAPI(secretKey: chatSessionSecretKey, currentMessage: currentMessage, time: now)
        print(response)
    }


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPerformanceOfInsertingMessage() throws {
        let secretKey = "TestSecretKey"
        let nickname = "TestUser"
        let dbTime: Int64 = Int64(Date().timeIntervalSince1970)
        let message = "Hello, world!"
        
        chatClient.ClearSessionTable()
        chatClient.AddSession(secretKey: secretKey, nickname: nickname, dbTime: dbTime)
        let sessions = chatClient.GetSessions()
        guard let session = sessions.last else {
            XCTFail("No session found")
            return
        }
        chatClient.ClearMessageTable()

        // Measure performance
        self.measure {
            chatClient.InsertMessage(sessionID: session.id, isUser: true, nickname: "123", message: message, dbTime: dbTime)
        }
    }
}

// FIXED: 前后端联调，postman用xxx数据格式和URLRequest格式不一样
