//
//  PlanGenerationSplashView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 24/02/26.
//

import SwiftUI

struct PlanGenerationSplashView: View {
    
    @EnvironmentObject var planManager: WorkoutPlanManager
    @State private var progress: Double = 0.0
    @State private var rotationAngle: Double = 0.0
    @State private var showPlanPreview: Bool = false
    var onDismiss: (() -> Void)? = nil
    
    private var phase: Int {
        if progress < 0.3 { return 1 }
        if progress < 0.6 { return 2 }
        if progress < 0.9 { return 3 }
        return 4
    }
    
    private var statusText: String {
        if progress < 0.3 { return "Analyzing your metrics..."}
        if progress < 0.6 { return "Optimizing for long-term progress..."}
        if progress < 0.9 { return "Finalizing exercise selection..."}
        return "Plan generated successfully!"
    }
    
    var body: some View {
        ZStack {
            if showPlanPreview {
                GeneratedPlanPreview(onDismiss: {
                    onDismiss?()
                })
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                splashContent
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showPlanPreview)
    }
    
    private var splashContent: some View {
        ZStack {
            ColorTheme.background
                .ignoresSafeArea()
            
            Circle()
                .fill(ColorTheme.secondary.opacity(0.15))
                .frame(width: 400,height: 400)
                .blur(radius: 100)
                .offset(x: 150, y: -300)
            
            Circle()
                .fill(ColorTheme.primary.opacity(0.1))
                .frame(width: 400,height: 400)
                .blur(radius: 100)
                .offset(x: -150, y: 300)
            
            VStack(spacing: 0) {
                HeaderView()
                    .padding(.top, 20)
                
                Spacer()
                
                // Central Animation Area
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        .frame(width: 320, height: 320)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .frame(width: 280, height: 280)
                    
                    OrbitingDot(radius: 140, speed: 4.0)
                    
                    ZStack {
                        TagView(icon: "target", text: planManager.currentPlan?.goal.displayName ?? "Hypertrophy", color: ColorTheme.primary)
                            .offset(y: -140)
                            .rotationEffect(.degrees(0))
                        
                        TagView(icon: "calendar", text: "\(planManager.currentPlan?.daysPerWeek ?? 4) Days/Week", color: ColorTheme.secondary)
                            .offset(y: -140)
                            .rotationEffect(.degrees(120))
                        
                        TagView(icon: "dumbbell.fill", text: planManager.currentPlan?.fitnessLevel.displayName ?? "Full Gym", color: ColorTheme.primary)
                            .offset(y: -140)
                            .rotationEffect(.degrees(240))
                    }
                    .rotationEffect(.degrees(rotationAngle))
                    
                    PulseRing()
                    
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(ColorTheme.secondary)
                            .shadow(color: ColorTheme.secondary.opacity(0.5), radius: 15)
                        
                        Text("PROCESSING")
                            .font(.system(size: 10, weight: .black))
                            .kerning(3)
                            .foregroundColor(ColorTheme.primary)
                    }
                }
                .frame(height: 380)
                
                Text(statusText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ColorTheme.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(0.9)
                    .padding(.top, 20)
                
                Spacer()
                
                // Progress Section
                VStack(spacing: 16) {
                    HStack {
                        Text("GENERATION PROGRESS")
                            .font(.system(size: 10, weight: .bold))
                            .kerning(1.5)
                            .foregroundColor(ColorTheme.textSecondary.opacity(0.4))
                        
                        Spacer()
                        
                        Text("PHASE 0\(phase)")
                            .font(.system(size: 10, weight: .bold))
                            .kerning(1.5)
                            .foregroundColor(ColorTheme.primary)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.05))
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(ColorTheme.buttonGradient)
                                .frame(width: geo.size.width * progress)
                                .shadow(color: ColorTheme.primary.opacity(0.3), radius: 5)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("Structured using proven training principles")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8)) {
                progress = 1.0
            }
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
        .task {
            // Use a default profile for now — later pass real user data
            let profile = UserProfile(id: .gainMuscle, age: 24, heightCM: 175, weightKG: 72, gender: .male)
            await planManager.generatePlan(for: profile, userId: "current-user")
        }
        .onChange(of: planManager.currentPlan != nil) { hasPlan in
            if hasPlan {
                withAnimation {
                    showPlanPreview = true
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}


struct HeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button {} label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(ColorTheme.primary)
                        .frame(width: 8, height: 8)
                        .shadow(color: ColorTheme.primary, radius: 4)
                    
                    Text("SYSTEM ONLINE")
                        .font(.system(size: 10, weight: .bold))
                        .kerning(2)
                        .foregroundColor(ColorTheme.textSecondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(ColorTheme.surface.opacity(0.5))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                
                Spacer()
                
                Color.clear.frame(width: 24)
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                Text("Building Your")
                Text("Training Plan")
            }
            .font(.system(size: 36, weight: .bold))
            .multilineTextAlignment(.center)
            .foregroundColor(ColorTheme.textPrimary)
        }
        .frame(height: 100)
    }
}

struct TagView: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(ColorTheme.surface.opacity(0.9))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(ColorTheme.secondary.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 10)
    }
}

struct OrbitingDot: View {
    let radius: CGFloat
    let speed: Double
    @State private var angle: Double = 0
    
    var body: some View {
        Circle()
            .fill(ColorTheme.secondary)
            .frame(width: 8, height: 8)
            .shadow(color: ColorTheme.secondary, radius: 12)
            .offset(y: -radius)
            .rotationEffect(.degrees(angle))
            .onAppear {
                withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                    angle = 360
                }
            }
    }
}

struct PulseRing: View {
    @State private var pulse: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .stroke(ColorTheme.primary.opacity(0.4), lineWidth: 2)
            .frame(width: 220, height: 220)
            .scaleEffect(pulse)
            .opacity(1.5 - Double(pulse))
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    pulse = 1.2
                }
            }
    }
}
