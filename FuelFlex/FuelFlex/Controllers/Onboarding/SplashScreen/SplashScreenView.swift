//
//  SplashScreenView.swift
//  FuelFlex
//
//  Created by sagar on 06/09/25.
//

import SwiftUI

struct SplashScreenView: View {
    
    @Binding var showSplash: Bool
    @State var animate: Bool = false
    @State var repeatCount: Int = 0
    
    var body: some View {
        ZStack {
            //background color
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: ColorTheme.background, location: 0.0),   // top
                    .init(color: ColorTheme.background, location: 0.5),   // middle
                    .init(color: ColorTheme.primary, location: 1.0)       // bottom
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: -4) {
                // Logo
                Image("fuelFlexLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260, height: 260)
                    .scaleEffect(animate ? 1.0 : 0.6)
                    .opacity(animate ? 1.0 : 0.3)
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                    .padding(.bottom, -16) // optional fine-tuning
                
                // Tagline
                VStack(spacing: 6) { // reduce spacing between texts
                    Text("FUEL YOUR BODY.")
                        .font(.custom("FXLogo-Bold", size: 26))
                    //                        .foregroundColor(ColorTheme.secondary.opacity(0.8))
                    
                    Text("FLEX YOUR LIMITS.")
                        .font(.custom("FXLogo-Bold", size: 30))
                    //                        .foregroundColor(ColorTheme.secondary.opacity(0.8))
                    
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [ColorTheme.secondary, Color.white],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .kerning(1.5)
                .padding(.vertical, 2)
                
            }
            
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.0)
                .repeatCount(3, autoreverses: true)
            ) {
                animate = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(showSplash: .constant(true))
}
