//
//  ChatExtension.swift
//  iChat
//
//  Created by 李子为 on 10/13/23.
//

import SwiftUI

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

struct BubbleShape: Shape {
    var isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        print(isUser)
        
        if isUser {
            path.move(to: CGPoint(x: rect.maxX - 10, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + 10, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY + 10), control: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 10))
            path.addQuadCurve(to: CGPoint(x: rect.minX + 10, y: rect.maxY), control: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY - 10), control: CGPoint(x: rect.maxX, y: rect.maxY))
            // Tail control
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 30))
            path.addQuadCurve(to: CGPoint(x: rect.maxX + 15, y: rect.minY + 25), control: CGPoint(x: rect.maxX + 10, y: rect.minY + 30))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        } else {
            path.move(to: CGPoint(x: rect.minX + 10, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 10), control: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 10))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - 10, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + 10, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - 10), control: CGPoint(x: rect.minX, y: rect.maxY))
            // Tail control
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 30))
            path.addQuadCurve(to: CGPoint(x: rect.minX - 15, y: rect.minY + 25), control: CGPoint(x: rect.minX - 10, y: rect.minY + 30))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }
        return path
    }
}

