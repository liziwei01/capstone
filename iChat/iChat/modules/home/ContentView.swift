//
//  ContentView.swift
//  iChat
//
//  Created by 李子为 on 9/17/23.
//

import SwiftUI

struct ContentView: View {
    @State private var sessions = client.GetSessions()
    @State private var showingSheet = false
    @State private var editMode = EditMode.inactive
    
    init() {
        client.startPolling()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(sessions.indices, id: \.self) { index in
                        HStack {
                            if editMode == .active {
                                Button(action: {
                                    removeSession(at: index)
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                                .padding(.trailing, 8)
                            }
                            
                            NavigationLink(destination: ChatDetailView(chatSession: sessions[index])) {
                                Text(sessions[index].nickname)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 70, maxHeight: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .contentShape(Rectangle())
                        .background(Color.white)
                        .border(Color.gray, width: 1)
                    }
                }
                
            }
        }
        .sheet(isPresented: $showingSheet) {
            NewChatSessionView { secretKey, nickname in
                print(secretKey)
                print(nickname)
                let dbTime: Int64 = Now()
                client.AddSession(secretKey: secretKey, nickname: nickname, dbTime: dbTime)
                sessions.append(ChatSession(id: Int32(sessions.count)+1, secretKey: secretKey, nickname: nickname, dbTime: dbTime))
                showingSheet = false
            }
        }
        .navigationBarTitle("Chats")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Settings") { SettingsView() }
            }
        }
        .environment(\.editMode, $editMode)
    }
    
    func removeSession(at index: Int) {
        let session = sessions[index]
        client.DeleteSession(sessionID: session.id)
        sessions.remove(at: index)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

