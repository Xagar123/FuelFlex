//
//  User.swift
//  FuelFlex
//
//  Created by sagar on 21/09/25.
//

import Foundation

struct User: Identifiable , Codable  {
    let id: String
    let fullName: String
    let email: String
    
    
    //to get the initial letter of name
    var initial: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullName: "Sagar das", email: "sagar@gmail.com ")
}
