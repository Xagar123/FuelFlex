//
//  FitnessLevelView.swift
//  FuelFlex
//

import SwiftUI

struct FitnessLevelView: View {
    
    @Binding var profile: UserProfile
    @State private var selectedLevel: FitnessLevel = .beginner
    @State private var selectedDays: Int = 4
    @State private var isNavigateNext: Bool = false
    
    let dayOptions = [3, 4, 5, 6]
    
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            
            Circle()
                .fill(ColorTheme.primary.opacity(0.05))
                .blur(radius: 100)
                .offset(x: -150, y: -200)
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        fitnessLevelSection
                        daysPerWeekSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
                
                continueButton
            }
            .navigationDestination(isPresented: $isNavigateNext) {
                UserGoalMatrixView(profile: $profile)
                    .preferredColorScheme(.dark)
            }
            .navigationBarBackButtonHidden()
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("YOUR FITNESS LEVEL")
                .font(.system(size: 24, weight: .black))
                .italic()
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("This helps us calibrate intensity and volume for your plan.")
                .font(.system(size: 14))
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
    
    // MARK: - Fitness Level Cards
    
    private var fitnessLevelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("EXPERIENCE LEVEL")
            
            ForEach(FitnessLevel.allCases, id: \.self) { level in
                let isSelected = selectedLevel == level
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedLevel = level
                    }
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? ColorTheme.primary.opacity(0.15) : Color.white.opacity(0.05))
                                .frame(width: 50, height: 50)
                            Image(systemName: level.icon)
                                .font(.system(size: 22))
                                .foregroundColor(isSelected ? ColorTheme.primary : ColorTheme.textSecondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(level.displayName.uppercased())
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(ColorTheme.textPrimary)
                            Text(level.description)
                                .font(.system(size: 12))
                                .foregroundColor(ColorTheme.textSecondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ColorTheme.primary)
                                .font(.system(size: 22))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(14)
                    .background(ColorTheme.surface.opacity(isSelected ? 1 : 0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(isSelected ? ColorTheme.primary : Color.white.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Days Per Week
    
    private var daysPerWeekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("TRAINING DAYS PER WEEK")
            
            HStack(spacing: 10) {
                ForEach(dayOptions, id: \.self) { days in
                    let isSelected = selectedDays == days
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDays = days
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text("\(days)")
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(isSelected ? ColorTheme.background : ColorTheme.textPrimary)
                            Text("days")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(isSelected ? ColorTheme.background.opacity(0.7) : ColorTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(isSelected ? ColorTheme.primary : ColorTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                }
            }
            
            Text(splitDescription)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ColorTheme.secondary)
                .padding(.top, 4)
        }
    }
    
    private var splitDescription: String {
        switch selectedDays {
        case 3: return "Recommended: Full Body Split"
        case 4: return "Recommended: Upper/Lower Split"
        default: return "Recommended: Push/Pull/Legs Split"
        }
    }
    
    // MARK: - Continue
    
    private var continueButton: some View {
        VStack(spacing: 20) {
            Button {
                profile.fitnessLevel = selectedLevel
                profile.daysPerWeek = selectedDays
                isNavigateNext = true
            } label: {
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
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
        .padding(.top, 10)
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(1.5)
            .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
    }
}

#Preview {
    NavigationStack {
        FitnessLevelView(profile: .constant(
            UserProfile(id: .gainMuscle, age: 24, heightCM: 175, weightKG: 72)
        ))
    }
    .preferredColorScheme(.dark)
}
