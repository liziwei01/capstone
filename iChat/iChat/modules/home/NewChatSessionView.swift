//
//  NewChatSessionView.swift
//  iChat
//
//  Created by 李子为 on 10/2/23.
//

import SwiftUI

struct NewChatSessionView: View {
    @State private var secretKey: String = ""
    @State private var nickname: String = ""
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

// FIXED: 弹窗addSession闭包调用

// UNFIXED: 输入Secret Key和Nickname会报错Error: this application, or a library it uses, has passed an invalid numeric value (NaN, or not-a-number) to CoreGraphics API and this value is being ignored. Please fix this problem. 定位不到问题
