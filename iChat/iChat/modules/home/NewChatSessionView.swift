//
//  NewChatSessionView.swift
//  iChat
//
//  Created by 李子为 on 10/2/23.
//

import SwiftUI

struct NewChatSessionView: View {
    @State private var secretKey = ""
    @State private var nickname = ""
    var addSession: (String, String) -> Void
    
    var body: some View {
        VStack {
            TextField("Secret Key", text: $secretKey)
                .padding()
            TextField("Nickname", text: $nickname)
                .padding()
            Button(action: {
                addSession(secretKey, nickname)
            }) {
                Text("Add Chat Session")
            }
            .padding()
        }
        .padding()
    }
}

struct NewChatSessionView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatSessionView { secretKey, nickname in
            print("Secret Key: \(secretKey), Nickname: \(nickname)")
        }
    }
}

