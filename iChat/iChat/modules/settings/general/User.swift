//
//  User.swift
//  iChat
//
//  Created by 李子为 on 9/29/23.
//

import SwiftUI

struct UserView: View {
    @State var confLocal = conf
    
    var body: some View {
        NavigationView {
            Form{
                TextField(
                    "your nickname",
                    text: $confLocal.Nickname
                )
            }
        }.navigationBarTitle("Nickname")
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
