//
//  ProfileView.swift
//  FuelFlex
//
//  Created by sagar on 07/09/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var spinRotation = 0.0
    
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
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(ColorTheme.textSecondary)
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
                                Text("Alex Rivers")
                                    .font(.title2.bold())
                                Image(systemName: "sword.fill")
                                    .foregroundColor(ColorTheme.primary)
                            }
                            Text("Elite Rank • Pro Member")
                                .font(.caption.bold())
                                .foregroundColor(.gray)
                                .tracking(1)
                        }
                    }
                    
                    // MARK: - Progress Card
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("HEALTH FUEL")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.gray)
                                Text("88%")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(ColorTheme.primary)
                            }
                            Spacer()
                            Image(systemName: "gauge.with.needle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(ColorTheme.primary)
                        }
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Next Goal: Cyborg Rank").font(.caption2.bold())
                                Spacer()
                                Text("62% Done").font(.caption2).foregroundColor(.gray)
                            }
                            
                            // Progress Bar
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.black.opacity(0.3)).frame(height: 10)
                                Capsule()
                                    .fill(ColorTheme.primary)
                                    .frame(width: 200, height: 10) // Mock 62%
                                    .shadow(color: ColorTheme.primary.opacity(0.4), radius: 5)
                            }
                        }
                        
                        // AI Tip
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(ColorTheme.secondary)
                            Text("\"Your body is ready! AI Tip: Do a quick 15-min workout to burn extra fat today.\"")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
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
                        StatBoxView(icon: "flame.fill", label: "Burned Today", value: "420 kcal", color: ColorTheme.accent)
                        StatBoxView(icon: "applelogo", label: "Food Quality", value: "A+ Grade", color: ColorTheme.primary)
                        StatBoxView(icon: "target", label: "Move Accuracy", value: "98%", color: ColorTheme.secondary)
                        StatBoxView(icon: "trophy.fill", label: "Day Streak", value: "24 Days", color: ColorTheme.golden)
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
                        
                        Button(action: {}) {
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
}

// MARK: - Subviews

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
    }
}
