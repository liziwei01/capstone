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
                        VStack(alignment: message.isUser ? .trailing : .leading) {
                            Text(message.nickname)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text(message.message)
                                .padding(10)
                                .background(BubbleShape(isUser: message.isUser)
                                    .fill(message.isUser ? Color.blue : Color.gray))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
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
                        let now = Now()
                        
                        // 1 Insert into local database
                        client.InsertMessage(sessionID: chatSession.id, isUser: true, nickname: conf.Nickname, message: currentMessage, dbTime: now)
                        
                        // 2 Send to server
                        _ = SendChatAPI(secretKey: chatSession.secretKey, currentMessage: currentMessage, time: now)
                        currentMessage = ""
                    }
                }
            }
        }
        .padding()
    }
}

struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChatDetailView(chatSession: ChatSession(id: 1, secretKey: "123key", nickname: "123key", dbTime: 12345678))
    }
}


