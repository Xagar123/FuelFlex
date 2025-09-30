//
//  GoalSelectionView.swift
//  FuelFlex
//
//  Created by sagar on 09/09/25.
//

import SwiftUI

struct GoalSelectionView: View {
    @State private var selectedGoal: String? = nil
    @State var isNavigation: Bool = false
    
    private let goals: [(String, String,String)] = [
        ("Lose Weight", "Burn fat and slim down with smarter workouts.","cardio"),
        ("Gain Muscle", "Build strength and grow lean muscle mass.","dumble"),
        ("Stay Fit", "Maintain a healthy and balanced lifestyle.","heartbeat")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.splashGradient.ignoresSafeArea()
                
                Image("running")
                    .resizable()
                //                .scaledToFit()
                //                .frame(maxWidth: .infinity)
                    .opacity(0.3)
                    .padding()
                
                VStack(spacing: 32) {
                    
                    // MARK: - Title
                    Text("What’s your goal?")
                        .font(.custom("Montserrat-Bold", size: 28))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // MARK: - Goal Options
                    VStack(spacing: 16) {
                        ForEach(goals, id: \.0) { goal, subtitle, iconName in
                            GoalOptionCard(
                                goal: goal,
                                subtitle: subtitle,
                                isSelected: selectedGoal == goal,
                                iconName: iconName
                            ) {
                                selectedGoal = goal
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // MARK: - Next Button
                    Button(action: {
                        // TODO: Navigate to GenderSelectionView
                        isNavigation = true
                       
                    }) {
                        Text("NEXT")
                            .font(.custom("Montserrat-SemiBold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorTheme.accentGradient)
                            .cornerRadius(16)
                            .shadow(color: ColorTheme.golden.opacity(0.3), radius: 8)
                    }
                 
                    .opacity(selectedGoal == nil ? 0.5 : 1)
                    .disabled(selectedGoal == nil)
                    .padding()
                    
                    NavigationLink("", destination: GenderSelectionView(),isActive: $isNavigation)
                }
                .padding(.horizontal, 24)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarBackButtonHidden()
        }
    }
}

struct GoalOptionCard: View {
    let goal: String
    let subtitle: String
    let isSelected: Bool
    let iconName: String
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 60)
                    .opacity(isSelected
                             ? 1.0 : 0.3)
                    .padding()
                    .padding(.trailing,-20)
            }
            
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.uppercased())
                        .font(.custom("Montserrat-Bold", size: 20))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.custom("Montserrat-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            isSelected
                            ? ColorTheme.accentGradient
                            : LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: isSelected ? ColorTheme.golden.opacity(0.4) : .clear, radius: 10)
            }
        }
    }
}



#Preview {
    GoalSelectionView()
}
