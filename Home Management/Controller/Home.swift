//
//  Home.swift
//  Home Management
//
//  Created by BaBaSaMa on 2/1/22.
//

import Foundation
import SwiftUI

struct Home: Identifiable, Hashable {
    let id = UUID()
    let home_id: String
    let home_name: String
    let invitation_status: String
}
