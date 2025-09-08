//
//  ContentView.swift
//  FuelFlex
//
//  Created by sagar on 06/09/25.
//

import SwiftUI

struct GetStartedView: View {
    
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0
    @State private var glow: Bool = false
    @State private var navigateToLogin = false
    
    var body: some View {
        ZStack {
            // Background Gradient (from ColorTheme)
            //            ColorTheme.getStartedGradient
            ColorTheme.splashGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Spacer()
                // Logo with bounce + glow
                Image("fuelFlexLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .scaleEffect(scale)
                    .shadow(color: glow ? ColorTheme.primary.opacity(0.8) : .clear,
                            radius: 20, x: 0, y: 0)
                    .onAppear {
                        withAnimation(.spring(response: 0.6,
                                              dampingFraction: 0.5,
                                              blendDuration: 0)) {
                            self.scale = 1.0
                        }
                        withAnimation(.easeInOut(duration: 1)
                            .repeatForever(autoreverses: true)) {
                                self.glow.toggle()
                            }
                    }
                
                Spacer()
                
                // MARK: - Branding & Motivation
                VStack(alignment: .leading, spacing: 10) {
                    // Tagline 1
                    Text("FUEL YOUR BODY.")
                        .font(.custom("FOX-Bold", size: 27))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTheme.primary, Color.white],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .kerning(1.0)
                    
                    // Tagline 2 - Main Hero
                    Text("FLEX YOUR LIMITS.")
                        .font(.custom("FXLogo-Bold", size: 36))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTheme.primary, Color.white],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .kerning(1.5)
                        .padding(.vertical, 2)
                    
                    // Motivational Subtext
                    Text("An AI-powered coach to guide your workouts and nutrition.\nStay consistent, stay unstoppable.")
                        .font(.custom("STIXTwoText_SemiBold", size: 14))
                        .foregroundColor(Color.white)
                        .lineSpacing(4)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 30)
                
                // MARK: - Get Started Button
                Button(action: {
                    navigateToLogin = true
                }) {
                    Text("Get Started")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorTheme.buttonGradientSoft)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 24)
                
                // MARK: - Sign In Option
                Button(action: {
                    navigateToLogin = true
                }) {
                    HStack {
                        Text("Already have an account?")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Text("Sign in")
                            .font(.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(ColorTheme.textPrimary)
                    }
                }
                .padding(.top)
                .padding(.bottom, 24)
            }
        }
        // Navigation to Login Screen
        .fullScreenCover(isPresented: $navigateToLogin) {
            LoginView()
        }
    }
}

#Preview {
    GetStartedView()
}
