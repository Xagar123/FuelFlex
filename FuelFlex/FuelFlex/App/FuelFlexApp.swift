//
//  FuelFlexApp.swift
//  FuelFlex
//
//  Created by sagar on 06/09/25.
//

import SwiftUI

@main
struct FuelFlexApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
   
    @StateObject var viewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
        }
    }
}


