//
//  AuthService.swift
//  FuelFlex
//
//  Created by sagar on 21/09/25.
//

import Foundation
import SwiftUI

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isUserLoggedIn: Bool = false
    
    private init() {
        // Check stored credentials, keychain, etc.
        isUserLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    func login() {
        // Perform login logic
        isUserLoggedIn = true
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
    }
    
    func logout() {
        // Perform logout logic
        isUserLoggedIn = false
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
}
