//
//  LoginView.swift
//  FuelFlex
//
//  Created by sagar on 07/09/25.
//

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

#Preview {
    LoginView()
}
