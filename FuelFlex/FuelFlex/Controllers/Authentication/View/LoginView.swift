//
//  LoginView.swift
//  FuelFlex
//
//  Created by sagar on 07/09/25.
//
/*
import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0
    @State private var glow: Bool = false
    @State private var isNavigateToDashboard = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel 
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ColorTheme.splashGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
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
                    
                    //                Spacer()
                    
                    // Email + Password
                    VStack(alignment: .leading,spacing: 0) {
                        FloatingLabelTextField(label: "Email", text: $email)
                        FloatingLabelTextField(label: "Password", text: $password, isSecure: true)
                    }
                    
                    // Login Button
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.signIn(withEmail: email, password: password)
                                // navigate to main app screen after successful login -> DashboardView
                                isNavigateToDashboard = true
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }) {
                        
                        Text("Log In")
                            .font(.custom("Montserrat-SemiBold", size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorTheme.buttonGradientLight)
                            .cornerRadius(16)
                            .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 0)
                    }
                    
                    // Forgot Password
                    Button(action: {}) {
                        Text("Forgot password?")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.footnote)
                    }
                    
                    // Divider
                    HStack {
                        Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.3))
                        Text("OR CONTINUE WITH")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                        Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.3))
                    }
                    .padding(.vertical, 10)
                    
                    
                    // Social Buttons
                    VStack(spacing: 12) {
                        Button(action: {}) {
                            HStack {
                                Image("google_logo")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Continue with Google")
                                    .font(.custom("Montserrat-Medium", size: 16))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 20, weight: .bold))
                                Text("Continue with Apple")
                                    .font(.custom("Montserrat-Medium", size: 16))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                    
                    // Sign Up Prompt
                    HStack {
                        Text("Don’t have an account?")
                            .foregroundColor(.white.opacity(0.8))
                        
                        NavigationLink {
                            SignupView()
                        } label: {
                            Text("SIGN UP")
                                .font(.custom("Montserrat-Bold", size: 14))
                                .foregroundColor(.white)
                        }

                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
                
            }
            .navigationDestination(isPresented: $isNavigateToDashboard) {
                MainTabView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}
 */

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isNavigateToDashboard = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoGlow: Bool = false
    @State private var animateFields: Bool = false
    
    @Environment(\.dismiss) var dismiss
    // In real app, ensure AuthViewModel is injected: @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var viewModel = MockAuthViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background Layer
                ColorTheme.background.ignoresSafeArea()
                
                // Ambient Glow Background
                Circle()
                    .fill(ColorTheme.primary.opacity(0.12))
                    .frame(width: 450, height: 450)
                    .blur(radius: 100)
                    .offset(x: 180, y: -250)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        headerSection
                        
                        inputSection
                        
                        actionSection
                        
                        socialSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal)
                
                VStack {
                    Spacer()
                    footerSection
                }
            }
            .navigationDestination(isPresented: $isNavigateToDashboard) {
                MainTabView()
                    .preferredColorScheme(.dark)
            }
            .navigationBarBackButtonHidden()
        }
    }
}

// MARK: - Subviews
private extension LoginView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer(minLength: 60)
            
            ZStack(alignment: .leading) {
                // Subtle Logo in background of text
                Image("fuelFlexLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .opacity(0.05)
                    .offset(x: 180, y: -20)
                
                VStack(alignment: .leading, spacing: -5) {
                    Text("WELCOME\nBACK")
                        .font(.system(size: 48, weight: .black))
                        .italic()
                        .lineSpacing(-10)
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Rectangle()
                        .fill(ColorTheme.primary)
                        .frame(width: 60, height: 5)
                        .padding(.top, 10)
                }
            }
            
            Text("Login to resume your high-performance coaching.")
                .font(.system(size: 16))
                .foregroundColor(ColorTheme.textSecondary)
                .padding(.top, 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var inputSection: some View {
        VStack(spacing: 20) {
            CyberTextField(label: "EMAIL ADDRESS", text: $email, icon: "envelope.fill")
            
            VStack(alignment: .trailing, spacing: 8) {
                CyberTextField(label: "PASSWORD", text: $password, icon: "lock.fill", isSecure: true)
                
                Button(action: { /* Forgot Password */ }) {
                    Text("FORGOT PASSWORD?")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(ColorTheme.primary)
                        .tracking(1)
                }
            }
        }
        .opacity(animateFields ? 1 : 0)
        .offset(y: animateFields ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateFields = true
            }
        }
    }
    
    var actionSection: some View {
        Button(action: {
            Task {
                do {
                    // try await viewModel.signIn(withEmail: email, password: password)
                    isNavigateToDashboard = true
                } catch {
                    print(error.localizedDescription)
                }
            }
        }) {
            HStack {
                Text("LOGIN")
                    .font(.system(size: 18, weight: .black))
                    .tracking(2)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(ColorTheme.buttonGradient)
            .cornerRadius(20)
            .shadow(color: ColorTheme.primary.opacity(0.3), radius: 15, x: 0, y: 10)
        }
    }
    
    var socialSection: some View {
        VStack(spacing: 20) {
            HStack {
                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                Text("OR CONTINUE WITH")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
                    .tracking(1)
                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
            }
            
            HStack(spacing: 16) {
                socialButton(icon: "apple.logo", label: "APPLE")
                socialButton(image: "google_logo", label: "GOOGLE") // Assuming you have google_logo in assets
            }
        }
    }
    
    func socialButton(icon: String? = nil, image: String? = nil, label: String) -> some View {
        Button(action: {}) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                } else if let image = image {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
                
                Text(label)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    var footerSection: some View {
        HStack {
            Text("NEW TO THE CLUB?")
                .font(.system(size: 12))
                .foregroundColor(ColorTheme.textSecondary)
            
            NavigationLink {
                SignupView()
            } label: {
                Text("SIGN UP")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(ColorTheme.primary)
            }
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [ColorTheme.background.opacity(0), ColorTheme.background], startPoint: .top, endPoint: .bottom)
                .frame(height: 80)
                .offset(y: -20)
        )
    }
}

#Preview {
    LoginView()
}
