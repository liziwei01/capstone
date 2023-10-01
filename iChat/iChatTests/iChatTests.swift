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
        // 在每个测试用例运行之前创建一个 ChatClient 的实例
        chatClient = ChatClient()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        // 在每个测试用例运行之后销毁 ChatClient 的实例
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
    
    // Test the creation of a session and retrieval of sessions.
    func testAddSessionAndGetSessions() {
        let secretKey = "TestSecretKey"
        let nickname = "TestUser"
        let dbTime: Int64 = Int64(Date().timeIntervalSince1970)
        
        chatClient.ClearSessionTable()

        chatClient.AddSession(secretKey: secretKey, nickname: nickname, dbTime: dbTime)
        chatClient.AddSession(secretKey: secretKey, nickname: nickname, dbTime: dbTime+1)

        let sessions = chatClient.GetSessions()

        XCTAssertTrue(sessions.count > 0, "Sessions should not be empty after adding a session")
    }
    
    // Test the insertion of a message and retrieval of messages for a session.
    func testInsertMessageAndGetMessages() {
        let message = "Hello, world!"
        let dbTime: Int64 = Int64(Date().timeIntervalSince1970)
        
        let sessions = chatClient.GetSessions()
        guard let session = sessions.last else {
            XCTFail("No session found")
            return
        }
        
        chatClient.ClearMessageTable()

        chatClient.InsertMessage(sessionID: session.id, message: message, dbTime: dbTime)

        let messages = chatClient.GetMessages(sessionID: session.id)

        XCTAssertTrue(messages.count > 0, "Messages should not be empty after inserting a message")
        XCTAssertEqual(messages.last?.message, message, "Inserted message should match the retrieved message")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
