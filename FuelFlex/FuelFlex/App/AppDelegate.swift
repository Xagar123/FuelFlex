//
//  AppDelegate.swift
//  FuelFlex
//
//  Created by sagar on 06/09/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        print("🚀 FuelFlex App Launched")
        for family in UIFont.familyNames {
            print("📂 Family: \(family)")
            for names in UIFont.fontNames(forFamilyName: family) {
                print("   👉 \(names)")
            }
        }


        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("🌙 App moved to background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("☀️ App coming back to foreground")
    }
}

