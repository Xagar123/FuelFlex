//
//  SignupView.swift
//  FuelFlex
//
//  Created by sagar on 07/09/25.
//

import SwiftUI

struct SignupView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0
    @State private var glow: Bool = false
    @State var isNavigation : Bool = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.splashGradient.ignoresSafeArea()
                
                VStack {
                    ScrollView {
                        VStack(spacing: 32) {
                            Spacer(minLength: 60)
                            
                            // MARK: - Header
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Create Account")
                                    .font(.custom("Montserrat-Bold", size: 32))
                                    .foregroundColor(.white)
                                
                                Text("Fuel your fitness journey with AI-powered workouts & nutrition.")
                                    .font(.custom("Montserrat-Regular", size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            
                            // MARK: - Input Fields
                            VStack(spacing: 0) {
                                FloatingLabelTextField(label: "Full Name", text: $name)
                                FloatingLabelTextField(label: "Email", text: $email)
                                FloatingLabelTextField(label: "Password", text: $password, isSecure: true)
                                FloatingLabelTextField(label: "Confirm Password", text: $confirmPassword, isSecure: true)
                            }
                            .padding(.horizontal, 24)
                            
                            // MARK: - Sign Up Button
                            Button(action: {
                                // Signup action
//                                isNavigation.toggle()
                                Task {
                                    try await viewModel.createUser(withEmail: email, password: password, fullName: name)
                                } 
                                
                            }) {
                                Text("SIGN UP")
                                    .font(.custom("Montserrat-SemiBold", size: 18))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(ColorTheme.accentGradient)
                                    .cornerRadius(16)
                                    .shadow(color: .white.opacity(0.3), radius: 8)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top)
                            
                            Spacer(minLength: 100) // push form up a bit
                        }
                    }
                    
                    // MARK: - Sticky Bottom Footer
                    HStack {
                        Text("Already have an account?")
                            .font(.custom("Montserrat-Regular", size: 14))
                            .foregroundColor(.white)
                        
                        Button(action: { dismiss() }) {
                            Text("LOG IN")
                                .font(.custom("Montserrat-Bold", size: 14))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    NavigationLink("", destination: GoalSelectionView(),isActive: $isNavigation)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarBackButtonHidden()
        }

    }
}

#Preview {
    SignupView()
}
