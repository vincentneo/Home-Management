//
//  User.swift
//  Home Management
//
//  Created by BaBaSaMa on 3/1/22.
//

import Foundation
struct User: Identifiable, Hashable {
    var id = UUID()
    let user_id: String
    let display_name: String
}
