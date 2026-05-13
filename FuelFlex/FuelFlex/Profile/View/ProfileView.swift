//
//  ProfileView.swift
//  FuelFlex
//
//  Created by sagar on 07/09/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var spinRotation = 0.0
    @EnvironmentObject var viewModel: AuthViewModel

    private var user: FuelFlexUser? { viewModel.currentUser }
    
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    
                    // MARK: - App Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(ColorTheme.primary)
                            Text("FUEL FLEX")
                                .font(.system(size: 18, weight: .black))
                                .italic()
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "gearshape.fill")
                                .padding(10)
                                .background(Color.white.opacity(0.05))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                .foregroundColor(ColorTheme.primary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Hero Profile Section
                    VStack(spacing: 16) {
                        ZStack {
                            // Spinning Ring
                            Circle()
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                                .foregroundColor(ColorTheme.primary.opacity(0.4))
                                .frame(width: 110, height: 110)
                                .rotationEffect(.degrees(spinRotation))
                                .onAppear {
                                    withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                                        spinRotation = 360
                                    }
                                }
                            
                            // Avatar
                            Circle()
                                .fill(ColorTheme.surface)
                                .frame(width: 96, height: 96)
                                .overlay(
                                    Text(user?.initials ?? "?")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(ColorTheme.primary)
                                )
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 2))
                            
                            // Level Tag
                            Text("Level 42")
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(ColorTheme.background)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                .offset(y: 48)
                        }
                        
                        VStack(spacing: 4) {
                            HStack {
                                Text(user?.fullName ?? "User")
                                    .font(.title2.bold())
                                Image(systemName: "sword.fill")
                                    .foregroundColor(ColorTheme.primary)
                            }
                            Text(user?.goal?.capitalized ?? "Fitness Enthusiast")
                                .font(.caption.bold())
                                .foregroundColor(.gray)
                                .tracking(1)
                        }
                    }
                    
                    // MARK: - Progress Card
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DAILY TARGET")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.gray)
                                Text("\(user?.dailyCalories ?? 0)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(ColorTheme.primary)
                                + Text(" kcal")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "bolt.heart.fill")
                                .font(.system(size: 32))
                                .foregroundColor(ColorTheme.primary)
                        }
                        
                        // Macro breakdown
                        HStack(spacing: 16) {
                            macroLabel("Protein", "\(user?.proteinGrams ?? 0)g", ColorTheme.secondary)
                            macroLabel("Carbs", "\(user?.carbsGrams ?? 0)g", ColorTheme.golden)
                            macroLabel("Fats", "\(user?.fatsGrams ?? 0)g", ColorTheme.accent)
                        }
                        
                        // User info row
                        HStack(spacing: 16) {
                            infoChip("Age", "\(user?.age ?? 0)")
                            infoChip("Height", "\(user?.heightCM ?? 0) cm")
                            infoChip("Gender", user?.gender?.capitalized ?? "--")
                        }
                    }
                    .padding(24)
                    .background(
                        ZStack {
                            ColorTheme.surface
                            LinearGradient(gradient: Gradient(colors: [ColorTheme.primary.opacity(0.1), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        }
                    )
                    .cornerRadius(32)
                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    .padding(.horizontal)
                    
                    // MARK: - Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatBoxView(icon: "flame.fill", label: "Daily Calories", value: "\(user?.dailyCalories ?? 0) kcal", color: ColorTheme.accent)
                        StatBoxView(icon: "figure.strengthtraining.traditional", label: "Fitness Level", value: user?.fitnessLevel?.capitalized ?? "--", color: ColorTheme.primary)
                        StatBoxView(icon: "scalemass.fill", label: "Weight", value: "\(user?.weightKG ?? 0) kg", color: ColorTheme.secondary)
                        StatBoxView(icon: "calendar", label: "Days / Week", value: "\(user?.daysPerWeek ?? 0) days", color: ColorTheme.golden)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Settings List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("APP SETTINGS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.leading)
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "cpu", label: "AI Training Style")
                            Divider().background(Color.white.opacity(0.05))
                            SettingsRow(icon: "waveform.path.ecg", label: "Heart Rate Sync")
                            Divider().background(Color.white.opacity(0.05))
                            SettingsRow(icon: "shield.fill", label: "Privacy & Safety")
                            Divider().background(Color.white.opacity(0.05))
                            SettingsRow(icon: "creditcard.fill", label: "My Subscription", isLast: true)
                        }
                        .background(ColorTheme.surface.opacity(0.5))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
                        
                        Button(action: { viewModel.signOut() }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.red.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red.opacity(0.2), lineWidth: 1))
                        }
                        .padding(.top, 10)
                        .padding(.bottom,90)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Helpers

    private func macroLabel(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .black))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.2), lineWidth: 1))
    }

    private func infoChip(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Reusable Subviews

struct StatBoxView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
                Circle().fill(color).frame(width: 6, height: 6)
                    .shadow(color: color, radius: 4)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.headline.bold())
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            ZStack {
                ColorTheme.surface
                LinearGradient(gradient: Gradient(colors: [color.opacity(0.15), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        )
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct SettingsRow: View {
    let icon: String
    let label: String
    var isLast: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(ColorTheme.secondary)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 14, weight: .semibold))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
