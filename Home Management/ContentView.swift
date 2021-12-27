//
//  ContentView.swift
//  Home Management
//
//  Created by BaBaSaMa on 26/12/21.
//

import SwiftUI

struct ContentView: View {
    @State private var login_required = false
    
    var body: some View {
        VStack {
            
        }
        .onAppear {
            check_login()
        }
        .sheet(isPresented: $login_required) {
            login_required = false
        } content: {
            LoginView()
                .navigationTitle("Login")
        }

    }
    
    private func check_login() {
        let defaults = UserDefaults.standard
        let user_id = defaults.string(forKey: "user_id")
        if user_id == nil {
            login_required = true
        }
    }
}
