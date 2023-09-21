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
    
    init() {
        ServerIPPort = "http://localhost:8090"
        GetChatRouterFormat = "/getChat?time=%@&key_nickname=%@"
        PostChatRouterFormat = "/postChat"
    }
}

var conf: Conf = Conf()
