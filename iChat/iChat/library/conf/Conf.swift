//
//  Conf.swift
//  iChat
//
//  Created by 李子为 on 9/21/23.
//

import SwiftUI

class Conf: ObservableObject {
    
    @Published var ServerIPPort: String
    @Published var GetChatRouterFormat: String
    @Published var PostChatRouterFormat: String
    
    @Published var Nickname: String
    
//    @Published var dbPath = ""
//    @Published var db: OpaquePointer?
    
    init() {
        ServerIPPort = "http://localhost:8090"
        GetChatRouterFormat = "/getChat?time=%@&key_nickname=%@"
        PostChatRouterFormat = "/postChat"
        Nickname = ""
    }
}

var conf: Conf = Conf()
