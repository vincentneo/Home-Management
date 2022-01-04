//
//  ContentView.swift
//  Home Management
//
//  Created by BaBaSaMa on 26/12/21.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    @State private var login_required: Bool = false
    let defaults = UserDefaults.standard
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        TabView {
            HomePageView()
                .tabItem {
                    Image(systemName: "house.circle")
                    Text("Home")
                }
                .tag(0)
                .tint(Color.black)
            AddItemPageView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Add")
                }
                .tag(1)
                .tint(Color.black)
            SettingsPageView(login_required: $login_required)
                .tabItem {
                    Image(systemName: "gear.circle")
                    Text("Settings")
                }
                .tag(2)
        }
        .onAppear(perform: {
            check_login()
        })
        .onChange(of: login_required, perform: { newValue in
            check_login()
        })
        .sheet(isPresented: $login_required) {
            login_required = false
        } content: {
            LoginView(shouldShowSheet: $login_required)
        }
    }
    
    private func check_login() {
        let user_id = defaults.string(forKey: "user_id")
        print("user id: \(user_id)")
        if user_id == nil {
            login_required = true
            return;
        }
    }
}
