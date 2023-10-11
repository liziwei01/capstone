//
//  Polling.swift
//  iChat
//
//  Created by 李子为 on 10/9/23.
//

import SwiftUI

extension ChatClient {

    // Setup timer
    func startPolling() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            self?.fetchAndUpdateChats()
        }
    }

    // Fetching chat and update database
    func fetchAndUpdateChats() {
        let sessions = self.GetSessions()
        for session in sessions {
            fetchAndUpdateChat(chatSession: session)
        }
    }
    
    func fetchAndUpdateChat(chatSession: ChatSession) {
        let lastTime = GetLatestChatTime(sessionID: chatSession.id)
        let url = URL(string: String(format: conf.ServerIPPort + conf.GetChatRouterFormat, lastTime, chatSession.secretKey.hashValue))!
        
        let responseData = GetRequest(url: url, headers: [:])
        if let data = responseData["data"] as? [[String: Any]], responseData["errno"] as? Int == 0 {
            for chat in data {
                if let time = chat["time"] as? Int64, let content = chat["content"] as? String {
                    // Check if the message is newer than the last message. If it is new, add it to the database
                    if time > lastTime {
                        // Decrypt to base64
                        let base64Encoded = AESDecrypt(input: content, key: chatSession.secretKey)
                        // Decrypt to json
                        if let base64Data = base64Encoded?.data(using: .utf8) {
                            if let decodedData = Data(base64Encoded: base64Data) {
                                do {
                                    let jsonObject = try JSONSerialization.jsonObject(with: decodedData, options: [])
                                    let contentDict = jsonObject as? [String: Any]
                                    // Insert into database
                                    self.InsertMessage(sessionID: chatSession.id, nickname: contentDict?["user_nickname"] as? String ?? "", message: contentDict?["body"] as? String ?? "", dbTime: time)
                                } catch {
                                    print("Error decoding JSON: \(error)")
                                }
                            } else {
                                print("Error decoding base64 string.")
                            }
                        }
                    }
                }
            }
        } else if let errMsg = responseData["errmsg"] as? String {
            print("Error: \(errMsg)")
        }
    }
}
