//
//  WorkoutRootView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 01/03/26.
//

import SwiftUI

enum WorkoutRoot {
    case splashScreen
    case weeklyPlan
    case dashboard
    
}

struct WorkoutRootView: View {
    
    @Binding var path: [String]
    @State var currentScreen: WorkoutRoot = .dashboard
    
    var body: some View {
            Group {
                switch currentScreen {
                case .splashScreen:
                    PlanGenerationSplashView(root: $currentScreen)
                case .weeklyPlan:
                    WeeklyPlanView(root: $currentScreen)
                case .dashboard:
                    WorkoutDashboardView(rootView: $currentScreen)
               
                }
            }
//            .navigationDestination(for: String.self) { value in
//                if value == "plan" {
//                    WeeklyPlanView(root: $currentScreen)
//                }
//            }
    }
}

//#Preview {
//    WorkoutRootView()
//}
