//
//  ContentView.swift
//  Home Management
//
//  Created by BaBaSaMa on 26/12/21.
//

import SwiftUI

struct ContentView: View {
    @State private var login_required: Bool = false
    @State private var isDarkMode: Bool = false
    @State private var search_item: String = ""
    let defaults = UserDefaults.standard
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    HStack {
                        Text("Category")
                            .font(.title3)
                            .fontWeight(.medium)
                        Spacer()
                        Button {
                            
                        } label: {
                            Text("View All")
                                .font(.caption)
                                .fontWeight(.regular)
                                .foregroundColor(Color.black)
                        }
                    }
                    .padding(.horizontal, 15)
                    .frame(width: maxWidth * 0.8, height: 40, alignment: .center)
                    HStack {
                        VStack {
                            Image("groceries_icon")
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .center)

                            Text("Groceries")
                        }
                        .frame(width: 100, height: 100, alignment: .center)
                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                        .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                    }
                    .frame(width: maxWidth, height: 100, alignment: .bottom)
                }
                .padding(.horizontal, 15)
                .frame(width: maxWidth * 0.8, height: 40, alignment: .center)
            }
            .navigationTitle("Welcome \(defaults.string(forKey: "display_name") ?? "User")")
            .toolbar {
                Button {
                    print("pressed")
                } label: {
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(isDarkMode ? Color.white : Color.black)
                }

            }
            .frame(width: maxWidth, height: maxHeight)
        }
        .searchable(text: $search_item)
        .onAppear {
            if (colorScheme == .dark) {
                
            }
            check_login()
        }
        .onChange(of: login_required, perform: { newValue in
            print("lg_r \(newValue)")
            //check_login()
        })
        .sheet(isPresented: $login_required) {
            login_required = false
        } content: {
            LoginView(shouldShowSheet: $login_required)
        }
    }
    
    private func check_login() {
        let user_id = defaults.string(forKey: "user_id")
        if user_id == nil {
            login_required = true
            return;
        }
    }
}
