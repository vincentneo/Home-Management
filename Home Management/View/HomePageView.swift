//
//  HomePageView.swift
//  Home Management
//
//  Created by BaBaSaMa on 26/12/21.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import AlertToast
import Drops

struct HomePageView: View {
    @State private var isDarkMode: Bool = false
    @State private var search_item: String = ""
    let defaults = UserDefaults.standard
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Category")
                        .font(.title3)
                        .fontWeight(.medium)
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("View All")
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundColor(Color.black)
                    }
                }
                .padding(.horizontal, 15)
                .frame(width: maxWidth * 0.95, height: 40, alignment: .center)
                
                ScrollView (.horizontal) {
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
                        VStack {
                            Image("toiletries_icon")
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .center)
                            
                            Text("Toiletries")
                        }
                        .frame(width: 100, height: 100, alignment: .center)
                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                        .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                        VStack {
                            Image("laundry_icon")
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .center)
                            
                            Text("Laundry")
                        }
                        .frame(width: 100, height: 100, alignment: .center)
                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                        .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                        VStack {
                            Image("health_icon")
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .center)
                            
                            Text("Health")
                        }
                        .frame(width: 100, height: 100, alignment: .center)
                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                        .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                        VStack {
                            Image("electronic_icon")
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .center)
                            
                            Text("Electronic")
                        }
                        .frame(width: 100, height: 100, alignment: .center)
                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                        .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                    }
                    .frame(height: 100, alignment: .center)
                    .padding(.horizontal, maxWidth * 0.05)
                }
                .frame(width: maxWidth, height: 100, alignment: .center)
                
                HStack {
                    Text("Groceries")
                        .font(.title3)
                        .fontWeight(.medium)
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Edit")
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundColor(Color.black)
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Color.black)
                            .font(.headline)
                    }
                }
                .padding(.horizontal, 15)
                .frame(width: maxWidth * 0.95, height: 40, alignment: .center)
                
                ScrollView (.vertical) {
                    VStack {
                        HStack {
                            Image("electronic_icon")
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .center)
                                .padding(.horizontal, 15)
                            
                            VStack {
                                Text("Bread")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(width: maxWidth * 0.4, alignment: .leading)
                                Text("Sunshine Soft White Bread")
                                    .font(.subheadline)
                                    .frame(width: maxWidth * 0.4, alignment: .leading)
                                Text("Price: $1.50")
                                    .font(.subheadline)
                                    .frame(width: maxWidth * 0.4, alignment: .leading)
                                Text("Expiry: 15/12/2021")
                                    .font(.subheadline)
                                    .frame(width: maxWidth * 0.4, alignment: .leading)
                            }
                            
                            Spacer()
                            
                            HStack {
                                Button  {
                                    
                                } label: {
                                    Image(systemName: "minus")
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .foregroundColor(.black)
                                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                                        .fill(Color.white))
                                }
                                
                                Button  {
                                    
                                } label: {
                                    Text("1")
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .foregroundColor(.black)
                                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                                        .fill(Color.white))
                                }
                                
                                Button  {
                                    
                                } label: {
                                    Image(systemName: "plus")
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .foregroundColor(.black)
                                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                                        .fill(Color.white))
                                }
                                
                            }
                            .padding(.horizontal, 15)
                        }
                        .frame(width: maxWidth * 0.9, height: 100, alignment: .center)
                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                        .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                    }
                }
                .frame(width: maxWidth * 0.95, alignment: .bottom)
            }
            .frame(height: maxHeight * 0.7, alignment: .top)
            .navigationTitle("Welcome \(defaults.string(forKey: "display_name") ?? "User")")
            .toolbar {
                Button {
                    print("pressed")
                } label: {
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(isDarkMode ? Color.white : Color.black)
                }
                
            }
        }
        .searchable(text: $search_item)
        .onAppear {
            if (colorScheme == .dark) {
                isDarkMode = true
            }
        }
        .onChange(of: colorScheme, perform: { newValue in
            if newValue == .dark {
                isDarkMode = true
            }
        })
    }
}
