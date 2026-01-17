//
//  GoalSelectionView.swift
//  FuelFlex
//
//  Created by sagar on 09/09/25.
//

import SwiftUI


struct Goal: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon : String
}

struct GoalSelectionView: View {
    @State var selectedGoalID: String? = "lose-weight"
    @State var isNavigation: Bool = false
    
    private var goals = [
        Goal(id: "lose-weight",
             title: "Lose Weight",
             description: "Burn fat and slim down with personalized cardio plans.",
             icon: "flame.fill"),
        Goal(id: "gain-muscle",
             title: "Gain Muscle",
             description: "Build strength and size with heavy lifting routines.",
             icon: "figure.strengthtraining.traditional"),
        Goal(id: "stay-fit",
             title: "Stay Fit",
             description: "Maintain your health and keep your energy levels high.",
             icon: "heart.fill")
    ]
    
    var body: some View {
        ZStack {
            ColorTheme.background
                .ignoresSafeArea()
            VStack(spacing: 0) {
                headerSection
                
                goalListSection
                
                footerSection
            }
            NavigationLink("", destination: CoreMatrixView(),isActive: $isNavigation)
        }
    }
}

// MARK: - Subviews
private extension GoalSelectionView {
    var headerSection: some View {
        VStack(spacing: 12) {
            Text("WHAT'S YOUR GOAL?")
                .font(.system(size: 28, weight: .black))
                .italic()
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("We'll tailor your workout experience based on your objective.")
                .font(.subheadline)
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 40)
        .padding(.bottom, 30)
    }
    
    var goalListSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(goals) { goal in
                    GoalCardView(
                        goal: goal,
                        isSelected: selectedGoalID == goal.id
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedGoalID = goal.id
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    var footerSection: some View {
        VStack(spacing: 24) {
            // Main Action Button
            Button(action: {
                // Action for continue
                isNavigation = true
            }) {
                HStack {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .black))
                        .tracking(2)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(ColorTheme.buttonGradient)
                .cornerRadius(20)
                .shadow(color: ColorTheme.primary.opacity(0.3), radius: 10, x: 0, y: 8)
            }
            
//            // Step Indicators
//            HStack(spacing: 8) {
//                Capsule()
//                    .fill(ColorTheme.primary)
//                    .frame(width: 32, height: 4)
//                
//                ForEach(0..<2) { _ in
//                    Circle()
//                        .fill(Color.white.opacity(0.2))
//                        .frame(width: 6, height: 6)
//                }
//            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
        .padding(.top, 10)
    }
}

// MARK: - Components
struct GoalCardView: View {
    let goal: Goal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                iconBadge
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title.uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Text(goal.description)
                        .font(.system(size: 13))
                        .foregroundColor(ColorTheme.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ColorTheme.primary)
                        .font(.system(size: 22))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorTheme.surface)
                    .opacity(isSelected ? 1.0 : 0.6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? ColorTheme.primary : Color.white.opacity(0.1), lineWidth: 2)
            )
            .shadow(color: isSelected ? ColorTheme.primary.opacity(0.12) : .clear, radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? ColorTheme.primary.opacity(0.15) : Color.white.opacity(0.05))
            
            Image(systemName: goal.icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? ColorTheme.primary : ColorTheme.secondary)
        }
        .frame(width: 56, height: 56)
    }
}



#Preview {
    GoalSelectionView()
}
