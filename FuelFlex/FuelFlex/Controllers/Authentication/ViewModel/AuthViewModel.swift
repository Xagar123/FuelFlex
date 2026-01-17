//
//  AuthViewModel.swift
//  FuelFlex
//
//  Created by sagar on 22/09/25.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var user: User?
    
    init() {
        
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        print("Sign in ......")
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
         print("create user......")
    }
    
    func signOut() {
        
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
         
    }
}
