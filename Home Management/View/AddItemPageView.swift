//
//  AddPageView.swift
//  Home Management
//
//  Created by BaBaSaMa on 2/1/22.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import AlertToast
import Drops

struct AddItemPageView: View {
    @State private var isDarkMode: Bool = false
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var price: String = "$"
    @State private var expiry: Bool = true
    @State private var expiry_date: Date = Date()
    @State private var have_stock: Bool = true
    @State private var stock: String = ""
    let defaults = UserDefaults.standard
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "plus")
                        .font(.title)
                        .frame(width: 120, height: 120, alignment: .center)
                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                        .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                    Spacer()
                    
                    VStack {
                        VStack (spacing: 5) {
                            Text("Title")
                                .font(.headline)
                                .fontWeight(.medium)
                                .frame(width: maxWidth * 0.55, alignment: .leading)
                            
                            TextField("Enter Title", text: $title)
                                .frame(width: maxWidth * 0.55, alignment: .leading)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                        .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                        VStack (spacing: 5)  {
                            Text("Description")
                                .font(.headline)
                                .fontWeight(.medium)
                                .frame(width: maxWidth * 0.55, alignment: .leading)
                            
                            TextField("Enter Description", text: $description)
                                .frame(width: maxWidth * 0.55, alignment: .leading)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                        .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                    }
                }
                .frame(width: maxWidth * 0.9, alignment: .center)
                
                HStack {
                    Text("Category")
                        .font(.title3)
                        .fontWeight(.medium)
                    Spacer()
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
                
                VStack (spacing: 5) {
                    Text("Price")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(width: maxWidth * 0.83, alignment: .leading)
                    TextField("Enter Price", text: $price)
                        .frame(width: maxWidth * 0.83, alignment: .center)
                        .textContentType(.password)
                        .keyboardType(.default)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                
                HStack {
                    Text("Expiry Date")
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer()
                    Toggle (isOn: $expiry) { }
                }
                .frame(width: maxWidth * 0.83, alignment: .center)
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                
                if expiry {
                    HStack {
                        Text("Expiry Date")
                            .font(.headline)
                            .fontWeight(.bold)
                        DatePicker(selection: $expiry_date, displayedComponents: .date) {
                        }
                        .datePickerStyle(.compact)
                    }
                    .frame(width: maxWidth * 0.83, alignment: .center)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                    .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                }
                
                HStack {
                    Text("Stock")
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer()
                    Toggle (isOn: $have_stock) { }
                }
                .frame(width: maxWidth * 0.83, alignment: .center)
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                
                if expiry {
                    VStack (spacing: 5) {
                        Text("Stock")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: maxWidth * 0.83, alignment: .leading)
                        TextField("Enter Stock", text: $stock)
                            .frame(width: maxWidth * 0.83, alignment: .center)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                    .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                }
                
                Button {
                    
                } label: {
                    Text("Add New Item")
                        .foregroundColor(isDarkMode ? Color.black : Color.white)
                }
                .frame(width: maxWidth * 0.8, height: 40, alignment: .center)
                .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                .fill(isDarkMode ? Color.white : Color.black))
                .padding(.vertical, 5)
            }
            .frame(height: maxHeight * 0.7, alignment: .top)
            .navigationTitle(Text("Add New Item"))

        }
        .onAppear {
            if colorScheme == .dark {
                isDarkMode = true
            }
        }
        .onChange(of: colorScheme) { newValue in
            if newValue == .dark {
                isDarkMode = true
            }
        }
    }
}
