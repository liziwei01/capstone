//
//  General.swift
//  iChat
//
//  Created by 李子为 on 9/21/23.
//

import SwiftUI

struct GeneralView: View {
    var body: some View {
        VStack{
            NavigationView {
                Form{
                    Section(header: Text("Server")) {
                        NavigationLink("Server Address") { ServerView() }
                    }
                }
            }
        }.navigationBarTitle("General")
    }
}

struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView()
    }
}
