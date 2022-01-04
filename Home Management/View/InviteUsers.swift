//
//  InviteUsers.swift
//  Home Management
//
//  Created by BaBaSaMa on 3/1/22.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import AlertToast
import Drops

struct InviteUsers: View {
    @Binding var add_user_show: Bool
    
    @State private var isDarkMode: Bool = false
    @State private var search_text: String = ""
    @State private var user_list: [User] = []
    @State private var filter_user_list: [User] = []
    
    @Binding var select_user_list: [User]
    let defaults = UserDefaults.standard
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationView {
            VStack {
                List (filter_user_list, id: \.self) { user in
                    User_Selection_Cell(curr_user: user, selected_user_list: $select_user_list)
                        .onTapGesture {
                            if (select_user_list.contains(where: { $0.user_id == user.user_id })) {
                                self.select_user_list.removeAll(where: { $0.user_id == user.user_id})
                                return
                            }
                            select_user_list.append(user)
                        }
                }
            }
            .onChange(of: search_text, perform: { newValue in
                guard !search_text.isEmpty else {
                    filter_user_list = user_list
                    return
                }
                
                filter_user_list = user_list.filter { $0.display_name.contains(newValue.lowercased()) }
            })
            .navigationTitle(Text("Invite Users"))
            .searchable(text: $search_text)
            .toolbar {
                Button  {
                    print(select_user_list)
                    add_user_show = false
                } label: {
                    Text("Done")
                }
            }
        }
        .onAppear {
            if (colorScheme == .dark) {
                isDarkMode = true
            }
            
            get_user_list()
        }
        .onChange(of: colorScheme) { newValue in
            if newValue == .dark {
                isDarkMode = true
            }
        }
    }
    
    func get_user_list() {
        var parameters = JSON()
        parameters["user_id"].string = defaults.string(forKey: "user_id")
        
        AF.request("https://api.babasama.com/home_management/users", method: .get, parameters: parameters).response { response in
            switch response.result {
            case .success(let value):
                let json_value = JSON(value)
                guard json_value["output"].stringValue == "success" else {
                    debugPrint(response)
                    return
                }
                for i in json_value["users"].arrayValue {
                    user_list.append(User(user_id: i["user_id"].stringValue, display_name: i["display_name"].stringValue))
                }
                filter_user_list = user_list
                
            case .failure(let error):
                debugPrint(response)
            }
        }
    }
}

struct User_Selection_Cell: View {
    var curr_user: User
    @Binding var selected_user_list: [User]
    
    var body: some View {
        HStack {
            Text("\(curr_user.display_name)")
                .fontWeight(.medium)
            Spacer()
            if (selected_user_list.contains(where: { $0.user_id == curr_user.user_id })) {
                Image(systemName: "checkmark")
                    .foregroundColor(Color.black)
            }
        }
    }
}
