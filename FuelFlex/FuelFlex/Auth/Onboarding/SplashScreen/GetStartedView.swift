//
//  ContentView.swift
//  FuelFlex
//
//  Created by sagar on 06/09/25.
//


import SwiftUI

struct GetStartedView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @State private var logoGlow: Bool = false
    @State private var navigateToLogin = false
    @State private var animateText = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            // MARK: - Background Layer
            ColorTheme.background.ignoresSafeArea()

            ZStack {
                Image("gym_hero_bg") // Replace with your high-res athletic asset
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .ignoresSafeArea()
                    .opacity(0.4) // Subtle visibility to maintain focus on UI
                
                // Multi-layered Overlay for Depth
                LinearGradient(
                    colors: [
                        ColorTheme.background,
                        ColorTheme.background.opacity(0.7),
                        ColorTheme.background.opacity(0.2),
                        ColorTheme.background.opacity(0.8),
                        ColorTheme.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Accent Ambient Glow
                RadialGradient(
                    colors: [ColorTheme.primary.opacity(0.15), .clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 600
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // MARK: - Logo Section
                Spacer()
                
                ZStack {
                    // Pulsing Ring
                    Circle()
                        .stroke(ColorTheme.primary.opacity(logoGlow ? 0.3 : 0.1), lineWidth: 0)
                        .frame(width: 240, height: 240)
                        .scaleEffect(logoGlow ? 1.2 : 1.0)
                    
                    Image("fuelFlexLogo") // Ensure this asset exists
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                        .scaleEffect(scale)
                        .shadow(color: ColorTheme.primary.opacity(logoGlow ? 0.6 : 0.2), radius: 30)
                }
                .onAppear {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        logoGlow.toggle()
                    }
                }
                
                Spacer()
                
                // MARK: - Messaging Section
                VStack(alignment: .leading, spacing: -5) {
                    Text("FUEL YOUR BODY.")
                        .font(.system(size: 24, weight: .bold))
                        .italic()
                        .foregroundColor(ColorTheme.textSecondary)
                        .opacity(animateText ? 1 : 0)
                        .offset(x: animateText ? 0 : -20)
                    
                    Text("FLEX YOUR\nLIMITS.")
                        .font(.system(size: 56, weight: .black))
                        .italic()
                        .lineSpacing(-10)
                        .foregroundColor(ColorTheme.textPrimary)
                        .opacity(animateText ? 1 : 0)
                        .offset(x: animateText ? 0 : -30)
                    
                    Rectangle()
                        .fill(ColorTheme.primary)
                        .frame(width: 80, height: 6)
                        .padding(.top, 15)
                        .scaleEffect(x: animateText ? 1 : 0, anchor: .leading)
                    
                    Text("The AI-powered coach that evolves with your sweat. Precision workouts. Elite nutrition. Zero excuses.")
                        .font(.system(size: 16))
                        .foregroundColor(ColorTheme.textSecondary)
                        .padding(.top, 20)
                        .padding(.trailing, 40)
                        .lineSpacing(4)
                        .opacity(animateText ? 0.8 : 0)
                }
                .padding(.horizontal, 30)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                        animateText = true
                    }
                }
                
                Spacer()
                
                // MARK: - Action Section
                VStack(spacing: 20) {
                    Button(action: { navigateToLogin = true }) {
                        HStack {
                            Text("GET STARTED")
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
                        .shadow(color: ColorTheme.primary.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    
                    Button(action: { navigateToLogin = true }) {
                        HStack(spacing: 4) {
                            Text("ALREADY A MEMBER?")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(ColorTheme.textSecondary)
                            Text("LOG IN")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(ColorTheme.primary)
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 30)
            }
        }
        .fullScreenCover(isPresented: $navigateToLogin) {
            LoginView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Preview
struct GetStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GetStartedView()
    }
}
