//
//  WorkoutRootView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 01/03/26.
//

import SwiftUI

enum WorkoutRoot {
    case weeklyPlan
    case dashboard
}

struct WorkoutRootView: View {
    
    @EnvironmentObject var planManager: WorkoutPlanManager
    @Binding var path: [String]
    @State var currentScreen: WorkoutRoot = .dashboard
    
    var body: some View {
        Group {
            switch currentScreen {
            case .weeklyPlan:
                WeeklyPlanView(root: $currentScreen)
            case .dashboard:
                WorkoutDashboardView(rootView: $currentScreen)
            }
        }
    }
}
