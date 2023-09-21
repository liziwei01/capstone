//
//  Settings.swift
//  iChat
//
//  Created by 李子为 on 9/21/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack{
            NavigationView {
                Form{
                    Section(header: Text("General")) {
                        NavigationLink("General") {
                            GeneralView()
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Settings")
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
