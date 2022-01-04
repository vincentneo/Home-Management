//
//  AddHomePageView.swift
//  Home Management
//
//  Created by BaBaSaMa on 3/1/22.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import AlertToast
import Drops

struct AddHomePageView: View {
    @Binding var add_new_home: Bool
    
    @State private var isDarkMode: Bool = false
    @State private var home_name: String = ""
    @State private var error_alert: AlertData = AlertData(display: false, message: "")
    @State private var loading_alert: AlertData = AlertData(display: false, message: "")
    
    @State private var add_user_show: Bool = false
    @State private var selected_user_list: [User] = []
    let defaults = UserDefaults.standard
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "plus")
                        .font(.title)
                        .frame(width: 85, height: 85, alignment: .center)
                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                        .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                    VStack {
                        Text("Home Name")
                            .frame(width: maxWidth * 0.6, alignment: .leading)
                        TextField("Home Name", text: $home_name)
                            .frame(width: maxWidth * 0.6, alignment: .leading)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical)
                    .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                    .fill(Color.init(hue: 2.10, saturation: 0.06, brightness: 0.85)))
                }
                
                
                HStack {
                    Text("User List")
                        .font(.title3)
                        .fontWeight(.medium)
                    Spacer()
                    Button {
                        add_user_show = true
                    } label: {
                        Text("Add Users")
                            .foregroundColor(isDarkMode ? Color.white : Color.black)
                    }
                }
                .padding(.horizontal, 15)
                .frame(width: maxWidth * 0.95, height: 40, alignment: .center)
                
                List (selected_user_list, id: \.self) { user in
                    Text("\(user.display_name)")
                }
                
                Button {
                    if home_name.isEmpty {
                        
                        return
                    }
                    loading_alert.display = true
                    loading_alert.message = "Loading..."
                    MakeNewHome()
                } label: {
                    Text("Create New Home")
                        .foregroundColor(isDarkMode ? Color.black : Color.white)
                }
                    .frame(width: maxWidth * 0.8, height: 40, alignment: .center)
                    .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                    .fill(isDarkMode ? Color.white : Color.black))
                    .padding(.vertical, 5)
            }
            .navigationTitle(Text("Add New Home"))
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button  {
                        add_new_home = false
                    } label: {
                        Text("Cancel")
                    }
                }
            })
            .frame(height: maxHeight * 0.7, alignment: .top)
            .sheet(isPresented: $add_user_show) {
                add_user_show = false
            } content: {
                InviteUsers(add_user_show: $add_user_show, select_user_list: $selected_user_list)
            }
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
        .toast(isPresenting: $error_alert.display, duration: 2.0, tapToDismiss: true, alert: {
            AlertToast(displayMode: .alert, type: .error(Color.red), title: error_alert.message)
        }, completion:  {
            error_alert = AlertData(display: false, message: "")
        })
        .toast(isPresenting: $loading_alert.display, duration: 60.0, tapToDismiss: false, alert: {
            AlertToast(displayMode: .alert, type: .loading, title: loading_alert.message)
        }, completion:  {
            loading_alert = AlertData(display: false, message: "")
        })
    }
    
    func MakeNewHome() {
        loading_alert.message = "Making New Home..."
        var parameters = JSON()
        parameters["user_id"].string = defaults.string(forKey: "user_id")
        
        AF.request("https://api.babasama.com/home_management/home/create", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: HTTPHeaders.init(["Content-Type": "application/json"])).response { response in
            switch response.result {
            case .success(let value):
                let json_value = JSON(value)
                guard json_value["output"].stringValue == "success" else {
                    error_alert.display = true
                    error_alert.message = json_value["message"].stringValue
                    debugPrint(response)
                    return
                }
                
                let home_id = json_value["home_id"].stringValue
                defaults.set("home_id", forKey: "home_id")
                Task {
                    await AddUserToHome(home_id)
                    await UpdateHomeName(home_id)
                }
                
                loading_alert.display = false
                if !error_alert.display {
                    Drops.show(Drop(title: "Successfully created new home", icon: UIImage(systemName: "checkmark"), duration: 2.0))
                    add_new_home = false
                }
            case .failure(let error):
                debugPrint(response)
                loading_alert.display = false
                error_alert.display = true
                error_alert.message = "\(error.errorDescription!)"
            }
        }
    }
    
    func AddUserToHome(_ home_id: String) async {
        loading_alert.message = "Adding Users..."
        var parameters = JSON()
        parameters["user_id"].string = defaults.string(forKey: "user_id")
        parameters["home_id"].string = home_id
        
        var user_failure: [String] = []
    
        for i in selected_user_list {
            parameters["new_user_id"].string = i.user_id
            
            AF.request("https://api.babasama.com/home_management/home/add_new_user", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: HTTPHeaders.init(["Content-Type": "application/json"])).response { response in
                switch response.result {
                case .success(let value):
                    let json_value = JSON(value)
                    guard json_value["output"] == "success" else {
                        user_failure.append(i.display_name)
                        return
                    }
                    
                case .failure(let error):
                    debugPrint(response)
                    user_failure.append(i.display_name)
                }
            }
        }
        
        if user_failure.count > 0 {
            loading_alert.display = false
            error_alert.display = true
            error_alert.message = "\(user_failure.joined(separator: ", ")) did not get added into the list."
        }
    }
    
    func UpdateHomeName(_ home_id: String) async {
        loading_alert.message = "Completing..."
        var parameters = JSON()
        parameters["user_id"].string = defaults.string(forKey: "user_id")
        parameters["home_id"].string = home_id
        parameters["home_name"].string = home_name
        
        AF.request("https://api.babasama.com/home_management/home/update_name", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: HTTPHeaders.init(["Content-Type": "application/json"])).response { response in
            switch response.result {
            case .success(let value):
                let json_value = JSON(value)
                guard json_value["output"] == "success" else {
                    error_alert.display = true
                    error_alert.message = json_value["message"].stringValue
                    debugPrint(response)
                    return
                }
                
            case .failure(let error):
                debugPrint(response)
                loading_alert.display = false
                error_alert.display = true
                error_alert.message = "\(error.errorDescription!)"
            }
        }
    }
}
