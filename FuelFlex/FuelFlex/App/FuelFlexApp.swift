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
    
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView(showSplash: $showSplash)
            } else {
                GetStartedView()
            }
        }
    }
}


