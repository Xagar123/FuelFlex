//
//  UserGoalMatrixView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 21/01/26.
//

import SwiftUI

// MARK: - Models
enum GoalID: String, Codable {
    case loseWeight = "lose-weight"
    case gainMuscle = "gain-muscle"
    case stayFit = "stay-fit"
    
    var displayName: String {
        switch self {
        case .loseWeight: return "Weight Loss"
        case .gainMuscle: return "Build Muscle"
        case .stayFit: return "Stay Fit"
        }
    }
}

struct UserProfile {
    var id: GoalID
    var age: Int
    var heightCM: Int
    var weightKG: Int
    var gender: Gender = .male
    var fitnessLevel: FitnessLevel = .beginner
    var daysPerWeek: Int = 4
}


struct UserGoalMatrixView: View {
//    let profile = UserProfile(id: .gainMuscle, age: 25, heightCM: 170, weightKG: 57)
    
    @State private var animatedCalories: Int = 0
    @State private var isAnimating = false
    @State private var showError = false
    @Binding var profile: UserProfile
    @EnvironmentObject var viewModel: AuthViewModel
    
    var stats: (calories: Int, protein: Int, carbs: Int, fats: Int) {
        let bmr = Double((10 * profile.weightKG) + (6 * profile.heightCM) - (5 * profile.age)) + 5.0
        let tdee = bmr * 1.55
        
        var targetCals = tdee
        switch profile.id {
        case .loseWeight: targetCals -= 500
        case .gainMuscle: targetCals += 300
        default: break
        }
        
        let p = Double(profile.weightKG) * 2.0
        let f = (targetCals * 0.25) / 9
        let c = (targetCals - (p * 4) - (f * 9)) / 4
        
        return (Int(targetCals), Int(p), Int(c), Int(f))
    }
    
    var body: some View {
        ZStack {
            // Background
            ColorTheme.background.ignoresSafeArea()
            
            // Background Glows
            BackgroundGlows()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    headerSection
                    heroCard
                    macroList
                    actionButton
                }
                .padding(.horizontal, 24)
            }
            .navigationBarBackButtonHidden(true)
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "Something went wrong")
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                isAnimating = true
            }
            startCalorieAnimation()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                    .font(.system(size: 12, weight: .black))
                Text("READY TO LAUNCH")
                    .font(.system(size: 10, weight: .black))
                    .tracking(4)
            }
            .foregroundColor(ColorTheme.primary)
            .padding(.top, 20)
            
            Text("THE PLAN.")
                .font(.system(size: 48, weight: .black, design: .default))
                .italic()
                .foregroundColor(ColorTheme.textPrimary)
            + Text("\nYOUR FUEL")
                .font(.system(size: 48, weight: .black, design: .default))
                .foregroundColor(ColorTheme.textSecondary.opacity(0.2))
        }
        .offset(y: isAnimating ? 0 : -20)
        .opacity(isAnimating ? 1 : 0)
    }
    
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text(profile.id.displayName.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .tracking(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle().fill(ColorTheme.primary).frame(width: 6, height: 6)
                    Text("VERIFIED")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(ColorTheme.primary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("DAILY ENERGY TARGET")
                    .font(.system(size: 10, weight: .black))
                    .tracking(2)
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.4))
                
                HStack(alignment: .bottom, spacing: 8) {
                    Text("\(animatedCalories)")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .italic()
                        .monospacedDigit()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(ColorTheme.primary)
                        Text("CALORIES")
                            .font(.system(size: 12, weight: .black))
                            .italic()
                            .foregroundColor(ColorTheme.primary)
                    }
                    .padding(.bottom, 12)
                }
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            HStack {
                statMiniView(label: "AGE", value: "\(profile.age)")
                Spacer()
                statMiniView(label: "HEIGHT", value: "\(profile.heightCM)cm")
                Spacer()
                statMiniView(label: "BODY MASS", value: "\(profile.weightKG)kg")
            }
        }
        .padding(32)
        .background(ColorTheme.cardGradient)
        .cornerRadius(40)
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isAnimating ? 1 : 0.9)
        .opacity(isAnimating ? 1 : 0)
    }
    
    private var macroList: some View {
        VStack(spacing: 12) {
            MacroRow(label: "PROTEIN (BUILD)", value: stats.protein, unit: "g", color: ColorTheme.primary, icon: "figure.strengthtraining.traditional", delay: 0.5)
            MacroRow(label: "ENERGY (CARBS)", value: stats.carbs, unit: "g", color: ColorTheme.secondary, icon: "bolt.horizontal.fill", delay: 0.7)
            MacroRow(label: "HEALTH (FATS)", value: stats.fats, unit: "g", color: ColorTheme.accent, icon: "flame.fill", delay: 0.9)
        }
    }
    
    private var actionButton: some View {
        Button(action: {
            Task {
                do {
                    try await viewModel.completeOnboarding(
                        profile: profile,
                        calories: stats.calories,
                        protein: stats.protein,
                        carbs: stats.carbs,
                        fats: stats.fats
                    )
                } catch {
                    viewModel.errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }) {
            HStack {
                Text("GO TO DASHBOARD")
                    .font(.system(size: 16, weight: .black))
                    .tracking(2)
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .black))
            }
            .foregroundColor(ColorTheme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(ColorTheme.buttonGradient)
            .cornerRadius(32)
            .shadow(color: ColorTheme.primary.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .padding(.top, 10)
        .padding(.bottom, 40)
        .offset(y: isAnimating ? 0 : 20)
        .opacity(isAnimating ? 1 : 0)
    }
    
    private func statMiniView(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .black))
                .foregroundColor(ColorTheme.textSecondary.opacity(0.3))
            Text(value)
                .font(.system(size: 18, weight: .black))
                .italic()
        }
    }
    
    private func startCalorieAnimation() {
        let target = stats.calories
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            if animatedCalories < target {
                animatedCalories += max(1, target / 100)
            } else {
                animatedCalories = target
                timer.invalidate()
            }
        }
    }
    
    // MARK: - Subviews
    struct MacroRow: View {
        let label: String
        let value: Int
        let unit: String
        let color: Color
        let icon: String
        let delay: Double
        
        @State private var show = false
        
        var body: some View {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(value)")
                            .font(.system(size: 20, weight: .black))
                        Text(unit)
                            .font(.system(size: 12, weight: .medium))
                            .italic()
                            .opacity(0.4)
                    }
                }
                
                Spacer()
                
                Capsule()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 60, height: 6)
                    .overlay(
                        GeometryReader { geo in
                            Capsule()
                                .fill(color)
                                .frame(width: show ? geo.size.width * 0.8 : 0)
                        }
                    )
            }
            .padding(20)
            .background(ColorTheme.cardGradient)
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                    show = true
                }
            }
        }
    }
}



struct BackgroundGlows: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(ColorTheme.primary.opacity(0.15))
                .blur(radius: 100)
                .offset(x: -150, y: -300)
            
            Circle()
                .fill(ColorTheme.secondary.opacity(0.15))
                .blur(radius: 100)
                .offset(x: 150, y: 300)
            
            // Grid texture
            Canvas { context, size in
                for x in stride(from: 0, to: size.width, by: 30) {
                    for y in stride(from: 0, to: size.height, by: 30) {
                        context.fill(Path(CGRect(x: x, y: y, width: 1, height: 1)), with: .color(Color.white.opacity(0.05)))
                    }
                }
            }
        }
    }
}

#Preview {
    let profile = UserProfile(id: .gainMuscle, age: 25, heightCM: 170, weightKG: 57, gender: .male)
    UserGoalMatrixView(profile: .constant(profile))
}
