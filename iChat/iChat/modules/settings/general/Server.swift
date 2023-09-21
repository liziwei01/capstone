//
//  Server.swift
//  iChat
//
//  Created by 李子为 on 9/21/23.
//

import SwiftUI

struct ServerView: View {
    @State var confLocal = conf
    
    var body: some View {
        NavigationView {
            Form{
                TextField(
                    "https://127.0.0.1:8080",
                    text: $confLocal.ServerIPPort
                )
            }
        }.navigationBarTitle("Server Address")
    }
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView()
    }
}
