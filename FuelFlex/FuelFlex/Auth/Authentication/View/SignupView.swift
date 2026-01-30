//
//  SignupView.swift
//  FuelFlex
//
//  Created by sagar on 07/09/25.
//
/*
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
                                isNavigation.toggle()
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
 */

import SwiftUI

// MARK: - Signup View
struct SignupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isNavigation: Bool = false
    
    // Mock ViewModel for previewing (In real app, use @EnvironmentObject)
    @StateObject private var viewModel = MockAuthViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ColorTheme.background.ignoresSafeArea()
                
                // Ambient Glow Background
                Circle()
                    .fill(ColorTheme.primary.opacity(0.1))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(x: -150, y: -200)
              
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        headerSection
                        
                        inputSection
                        
                        actionSection
                        
                        Spacer(minLength: 40)
                       
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top,-35)
                
                VStack {
                    Spacer()
                    footerSection
                }
            }
            .navigationDestination(isPresented: $isNavigation) {
//                CoreMatrixView() // Navigating to the Matrix screen we built
                GoalSelectionView()
            }
            .navigationBarBackButtonHidden()
        }
    }
}

// MARK: - Subviews
private extension SignupView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer(minLength: 60)
            
            Text("CREATE\nACCOUNT")
                .font(.system(size: 42, weight: .black))
                .italic()
                .lineSpacing(-5)
                .foregroundColor(ColorTheme.textPrimary)
            
            Rectangle()
                .fill(ColorTheme.primary)
                .frame(width: 60, height: 4)
            
            Text("Fuel your fitness journey with AI-powered workouts & nutrition.")
                .font(.system(size: 16))
                .foregroundColor(ColorTheme.textSecondary)
                .padding(.trailing, 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var inputSection: some View {
        VStack(spacing: 20) {
            CyberTextField(label: "FULL NAME", text: $name, icon: "person.fill")
            CyberTextField(label: "EMAIL ADDRESS", text: $email, icon: "envelope.fill")
            CyberTextField(label: "PASSWORD", text: $password, icon: "lock.fill", isSecure: true)
            CyberTextField(label: "CONFIRM PASSWORD", text: $confirmPassword, icon: "lock.shield.fill", isSecure: true)
        }
    }
    
    var actionSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                // Perform Signup logic
                isNavigation = true
            }) {
                HStack {
                    Text("START JOURNEY")
                        .font(.system(size: 18, weight: .black))
                        .tracking(2)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(ColorTheme.buttonGradient)
                .cornerRadius(20)
                .shadow(color: ColorTheme.primary.opacity(0.3), radius: 15, x: 0, y: 10)
            }
            
            Text("By signing up, you agree to our Terms of Service.")
                .font(.system(size: 12))
                .foregroundColor(ColorTheme.textSecondary.opacity(0.6))
        }
    }
    
    var footerSection: some View {
        HStack {
            Text("Already have an account?")
                .font(.system(size: 14))
                .foregroundColor(ColorTheme.textSecondary)
            
            Button(action: { dismiss() }) {
                Text("LOG IN")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(ColorTheme.primary)
            }
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [ColorTheme.background.opacity(0), ColorTheme.background], startPoint: .top, endPoint: .bottom)
                .frame(height: 100)
                .offset(y: -20)
        )
    }
}

// MARK: - Components
struct CyberTextField: View {
    let label: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .tracking(1)
                .foregroundColor(isFocused ? ColorTheme.primary : ColorTheme.textSecondary.opacity(0.7))
            
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? ColorTheme.primary : ColorTheme.textSecondary.opacity(0.4))
                    .frame(width: 20)
                
                if isSecure {
                    SecureField("", text: $text)
                        .focused($isFocused)
                        .foregroundColor(.white)
                } else {
                    TextField("", text: $text)
                        .focused($isFocused)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.none)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(ColorTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isFocused ? ColorTheme.primary.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

// MARK: - Mock ViewModel for Preview
class MockAuthViewModel: ObservableObject {
    func createUser(withEmail: String, password: String, fullName: String) async throws {
        // Mock implementation
    }
}


#Preview {
    SignupView()
}
