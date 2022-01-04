//
//  SettingsPageView.swift
//  Home Management
//
//  Created by BaBaSaMa on 2/1/22.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import AlertToast
import Drops

struct SettingsPageView: View {
    let defaults = UserDefaults.standard

    @Binding var login_required: Bool
    
    @State private var notifyExpire: Bool = true
    @State private var notifyChanges: Bool = true
    
    @State private var error_alert: AlertData = AlertData(display: false, message: "")
    @State private var loading_alert: AlertData = AlertData(display: false, message: "")
    
    @State private var isDarkMode: Bool = false
    @State private var logoutAlert: Bool = false
    @State private var display_name: String = ""
    @State private var home_list: [Home] = []
    @State private var home_selection: String = ""
    
    @State private var add_new_home: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section  {
                        TextField("Display Name", text: $display_name)
                            .foregroundColor(isDarkMode ? Color.white : Color.black)
                    } header: {
                        Text("display name")
                    }
                    
                    Section  {
                        List (home_list, id: \.self) { home in
                            HomeListCell(home: home, selectedHome: $home_selection)
                        }
                        Button  {
                            add_new_home = true
                        } label: {
                            Text("Add New Home")
                                .fontWeight(.medium)
                        }

                    } header: {
                        Text("home list")
                    }
                    
                    Section  {
                        Toggle(isOn: $notifyExpire) {
                            Text("Notify me when an item is about to expire")
                        }
                        Toggle(isOn: $notifyChanges) {
                            Text("Notify me when there is a change")
                        }
                    } header: {
                        Text("notification")
                    }
                    
                    Section  {
                        Button {
                            logoutAlert = true
                        } label: {
                            Text("Logout")
                                .foregroundColor(Color.red)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
            .navigationTitle(Text("Settings"))
        }
        .onAppear {
            if (colorScheme == .dark) {
                isDarkMode = true
            }
            
            display_name = defaults.string(forKey: "display_name") ?? ""
            home_selection = defaults.string(forKey: "home_id") ?? ""
            getHomes()
        }
        .onChange(of: colorScheme, perform: { newValue in
            if newValue == .dark {
                isDarkMode = true
            }
        })
        .onChange(of: add_new_home, perform: { newValue in
            getHomes()
        })
        .onChange(of: home_selection, perform: { newValue in
            defaults.set(newValue, forKey: "home_id")
            if home_list.contains(where: { $0.home_id == home_selection && $0.invitation_status == "Invited" }) {
                setHomeStaying()
            }
        })
        .toast(isPresenting: $error_alert.display, duration: 2.0, tapToDismiss: true, alert: {
            AlertToast(displayMode: .alert, type: .error(Color.red), title: error_alert.message)
        }, completion: {
            error_alert = AlertData(display: false, message: "")
        })
        .toast(isPresenting: $loading_alert.display, duration: 60.0, tapToDismiss: false, alert: {
            AlertToast(displayMode: .alert, type: .loading, title: loading_alert.message)
        }, completion: {
            loading_alert = AlertData(display: false, message: "")
        })
        .alert("Logout", isPresented: $logoutAlert, actions: {
            Button("Cancel", role: .cancel) {}
            Button("Ok", role: nil) {
                defaults.removeObject(forKey: "user_id")
                defaults.removeObject(forKey: "display_name")
                
                login_required = true
            }
        }, message: {
            Text("are you sure you want to logout?")
        })
        .sheet(isPresented: $add_new_home) {
            add_new_home = false
        } content: {
            AddHomePageView(add_new_home: $add_new_home)
        }

    }
    
    func getHomes() {
        home_list = []
        let user_id = defaults.string(forKey: "user_id")
        guard let user_id = user_id else { return }
        
        var parameters = JSON()
        parameters["user_id"].string = user_id
        AF.request("https://api.babasama.com/home_management/home/list", method: .get, parameters: parameters).response { response in
            switch (response.result) {
            case .success(let value):
                let json_value = JSON(value)
                guard json_value["output"] == "success" else {
                    error_alert.display = true
                    error_alert.message = json_value["message"].stringValue
                    debugPrint(response)
                    return
                }
                
                for i in json_value["home"].arrayValue {
                    home_list.append(Home(home_id: i["home_id"].stringValue, home_name: i["home_name"].stringValue, invitation_status: i["invitation_status"].stringValue))
                }
                
            case .failure(let error):
                error_alert.display = true
                error_alert.message = "\(error.errorDescription!)"
                debugPrint(response)
            }
        }
    }
    
    func setHomeStaying() {
        var parameters = JSON()
        parameters["user_id"].string = defaults.string(forKey: "user_id") ?? ""
        parameters["home_id"].string = defaults.string(forKey: "home_id") ?? ""
        
        AF.request("https://api.babasama.com/home_management/home/update_invitation", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: HTTPHeaders.init(["Content-Type": "application/json"])).response { response in
            switch response.result {
            case .success(let value):
                let json_value = JSON(value)
                guard json_value["output"] == "success" else {
                    error_alert.display = true
                    error_alert.message = json_value["message"].stringValue
                    debugPrint(response)
                    return
                }
                
                getHomes()
            case .failure(let error):
                error_alert.display = true
                error_alert.message = "\(error.errorDescription!)"
                debugPrint(response)
            }
        }
    }
}

struct HomeListCell: View {
    let home: Home
    @Binding var selectedHome: String
    
    var body: some View {
        HStack {
            Text(home.home_name)
            Spacer()
            Text(home.invitation_status)
                .foregroundColor(Color.gray)
                .font(.subheadline)
            if home.home_id == selectedHome {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .onTapGesture {
            self.selectedHome = self.home.home_id
        }
    }
}
