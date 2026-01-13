//
//  GenderSelectionView.swift
//  FuelFlex
//
//  Created by sagar on 09/09/25.
//

import SwiftUI

import SwiftUI

struct GenderSelectionView: View {
    @State private var selectedGender: String? = nil
    
    var body: some View {
        ZStack {
            // Background with gradient + light overlay
            ColorTheme.splashGradient.ignoresSafeArea()
            
            VStack(spacing: 32) {
                
                // MARK: - Header
                Text("Tell us your gender")
                    .font(.custom("Montserrat-Bold", size: 32))
                    .foregroundColor(.white)
                    .padding(.top, 80)
                
                Spacer()
                
                // MARK: - Gender Options
                HStack(spacing: 24) {
                    genderOption(title: "Male", image: "figure.walk")
                    genderOption(title: "Female", image: "figure.dress.line.vertical.figure")
                }
                
                Spacer()
                
                // MARK: - Next Button
                Button(action: {
                    // Navigate to AgeSelectionView
                }) {
                    Text("NEXT")
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorTheme.accentGradient)
                        .cornerRadius(16)
                        .shadow(color: ColorTheme.golden.opacity(0.3), radius: 8)
                }
                .padding()
                .opacity(selectedGender == nil ? 0.5 : 1)
                .disabled(selectedGender == nil)
            }
            .padding(.horizontal, 24)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Gender Option Card
    private func genderOption(title: String, image: String) -> some View {
        Button(action: {
            selectedGender = title
        }) {
            VStack(spacing: 16) {
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.white)
                
                Text(title.uppercased())
                    .font(.custom("Montserrat-Bold", size: 18))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        selectedGender == title
                        ? ColorTheme.accentGradient
                        : LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: selectedGender == title ? ColorTheme.golden.opacity(0.4) : .clear, radius: 10)
        }
    }
}


#Preview {
    GenderSelectionView()
}
