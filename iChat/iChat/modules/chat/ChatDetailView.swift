//
//  Chat.swift
//  iChat
//
//  Created by 李子为 on 10/9/23.
//

import SwiftUI

struct ChatDetailView: View {
    @Binding var chatSession: ChatSession
    @State private var currentMessage: String = ""
    @ObservedObject var observer: ChatObserver

    // Fetching the messages when the view appears
    init(chatSession: ChatSession) {
        _chatSession = Binding.constant(chatSession)
        _observer = ObservedObject(initialValue: ChatObserver(sessionID: chatSession.id))
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(observer.messages.sorted(by: { $0.dbTime < $1.dbTime }), id: \.self) { message in
                        Text(message.message)
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .onAppear {
                observer.refreshMessages()
            }
            
            HStack {
                TextField("Enter message...", text: $currentMessage)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                Button("Send") {
                    if !currentMessage.isEmpty {
                        let now = Int64(Date().timeIntervalSince1970)
                        
                        // 1 Insert into local database
                        client.InsertMessage(sessionID: chatSession.id, nickname: conf.Nickname, message: currentMessage, dbTime: now)
                        
                        // 2 Send to server
                        let contentDict: [String: Any] = ["user_nickname": conf.Nickname, "body": currentMessage]
                        if let jsonData = try? JSONSerialization.data(withJSONObject: contentDict, options: []),
                           let base64Encoded = String(data: jsonData.base64EncodedData(), encoding: .utf8),
                           let encryptedContent = AESEncrypt(input: base64Encoded, key: chatSession.secretKey) {
                            let chatBodyDict: [String: Any] = [
                                "data": [
                                    ["time": now, "content": encryptedContent]
                                ]
                            ]

                            let postBody: [String: Any] = [
                                "key_nickname": conf.Nickname,
                                "chat_body": chatBodyDict
                            ]

                            if let postBodyData = try? JSONSerialization.data(withJSONObject: postBody, options: []) {
                                let url = URL(string: String(format: conf.ServerIPPort + conf.PostChatRouterFormat))!
                                let headers: [String: String] = [:]
                                _ = PostRequest(url: url, headers: headers, body: postBodyData)
                            }
                        }
                        currentMessage = ""
                    }
                }
            }
        }
        .padding()
    }
}

// Implement ChatDatabaseObserver protocol
class ChatObserver: ObservableObject, ChatDatabaseObserver {
    @Published var messages: [ChatMessage] = []

    let sessionID: Int32

    init(sessionID: Int32) {
        self.sessionID = sessionID
        self.messages = client.GetMessages(sessionID: sessionID)
        client.addObserver(self)
    }

    deinit {
        client.removeObserver(self)
    }

    func messagesUpdated(sessionID: Int32) {
        if self.sessionID == sessionID {
            messages = client.GetMessages(sessionID: sessionID)
        }
    }
    
    func refreshMessages() {
        self.messages = client.GetMessages(sessionID: self.sessionID)
    }
}


struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChatDetailView(chatSession: ChatSession(id: 1, secretKey: "123key", nickname: "123key", dbTime: 12345678))
    }
}


