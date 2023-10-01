//
//  ContentView.swift
//  iChat
//
//  Created by 李子为 on 9/17/23.
//

import SwiftUI

struct ContentView: View {
    @State private var sessions = client.GetSessions()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sessions) { session in
                    NavigationLink(destination: Text("对话界面 \(session.nickname)")) {
                        HStack {
                            Text(session.nickname)
                            Spacer()
                            Text("\(session.dbTime)")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationBarTitle("聊天")
            .navigationBarItems(trailing:
                Button(action: {
                    // 处理加号按钮点击
                    print("Add Button Tapped!")
                }) {
                    Image(systemName: "plus")
                }
            )
        }
    }
    
    // 从列表中删除聊天会话
    private func deleteItems(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
