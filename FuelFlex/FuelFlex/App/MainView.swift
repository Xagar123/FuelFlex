//
//  MainView.swift
//  FuelFlex
//
//  Created by sagar on 22/09/25.
//

import SwiftUI

struct MainView: View {
    @State private var showSplash = true
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession  != nil {
                SplashScreenView(showSplash: $showSplash)
            } else {
                GetStartedView()
            }
        }
    }
}

#Preview {
    MainView()
}
